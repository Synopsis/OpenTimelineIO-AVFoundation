//
//  Timeline.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import CoreMedia
import AVFoundation
import OpenTimelineIO
import TimecodeKit

public class VideoCompositionValidator : NSObject, AVVideoCompositionValidationHandling
{
    public func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidValueForKey key: String) -> Bool
    {
        return false
    }
    
    public func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingEmptyTimeRange timeRange: CMTimeRange) -> Bool
    {
        return true
    }
    
    public func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidTimeRangeIn videoCompositionInstruction: AVVideoCompositionInstructionProtocol) -> Bool
    {
        return false
    }
    
    public func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidTrackIDIn videoCompositionInstruction: AVVideoCompositionInstructionProtocol, layerInstruction: AVVideoCompositionLayerInstruction, asset: AVAsset) -> Bool
    {
        return false
    }
}

public extension Timeline
{
    
    // Some running notes about this conversion
    
    // 1 - Tracks
    // In a mutable composition, tracks must have compatible CMFormatDescriptions for different assets to be inserted
    // This is not like the more abstract representation of tracks in OTIO, where any external reference can follow any other in a nice fasion
    // So we cannot 1:1 make an AVCompositionTrack for every OTIO Track. We may have one to many, depending on underlying asset format descriptions
    // So here, we effectively ignore OTIO tracks and use the assets to see if we have compatible tracks.
    // If we do - great. if we dont, we make a new one.
    
    func toAVCompositionRenderables(baseURL:URL? = nil, customCompositorClass:AVVideoCompositing.Type? = nil, useAssetTimecode:Bool = true, rescaleToAsset:Bool = true) async throws -> (composition:AVComposition, videoComposition:AVVideoComposition, audioMix:AVAudioMix)?
    {
        // OTIO Timelines for the current schema version does not support a well described timeline format - ie no resolution or framerate
        // We deduce this via a heuristic here...
        
        var largestRasterSizeFound = CGSize.zero
        
        let validator = VideoCompositionValidator()
        
        // Get our global offset - if we have one, to normalize track times
        let globalStartCMTime = self.globalStartTime?.toCMTime() ?? .zero
        
        let options =  [AVURLAssetPreferPreciseDurationAndTimingKey : true] as [String : Any]

        let composition = AVMutableComposition(urlAssetInitializationOptions: options)
        let audioMix = AVMutableAudioMix()

        // All rendering instructions for our tracks / segments 
        var compositionVideoInstructions = [AVVideoCompositionInstruction]()
        var compositionAudioMixParams = [AVAudioMixInputParameters]()

        for track in self.videoTracks
        {
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)

//            let transitions:[Transition] = track.children.compactMap( { guard let transition = $0 as? Transition else { return nil }; return transition })
            
            let items:[Item] = track.children.compactMap( { guard let item = $0 as? Item else { return nil }; return item })

            for item in items
            {
                guard
                    let clip = item as? Clip,
                    let (sourceAsset, clipTimeMapping) = try clip.toAVAssetAndMapping(baseURL: baseURL, trackType:.video, useTimecode: useAssetTimecode, rescaleToAsset: rescaleToAsset),
                    let sourceAssetFirstVideoTrack = try await sourceAsset.loadTracks(withMediaType: .video).first,
                    let compositionVideoTrack = compositionVideoTrack //composition.mutableTrack(compatibleWith: sourceAssetFirstVideoTrack) ??
                else
                {
                    // TODO: GAP !?
                    if let gap = item as? Gap,
                       let compositionVideoTrack = compositionVideoTrack
                    {
                        do
                        {
                            let gapTimeRangeOTIO = try gap.trimmedRangeInParent() ?? gap.rangeInParent()
                            let gapTimeRange = gapTimeRangeOTIO.toCMTimeRange()
                            
                            guard
                                gapTimeRange.duration != .zero
                            else
                            {
                                continue
                            }
                            
                            compositionVideoTrack.insertEmptyTimeRange(gapTimeRange)
                            compositionVideoTrack.preferredTransform = .identity

                            let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                            let compositionLayerInstructions = [compositionLayerInstruction]

                            // Video Composition Instruction
                            let compositionVideoInstruction = AVMutableVideoCompositionInstruction()
                            compositionVideoInstruction.layerInstructions = compositionLayerInstructions
                            compositionVideoInstruction.timeRange = gapTimeRange
                            compositionVideoInstruction.enablePostProcessing = false
                            compositionVideoInstruction.backgroundColor = CGColor(gray: 0, alpha: 0)
                            compositionVideoInstructions.append( compositionVideoInstruction)
                        }
                        catch
                        {
                            continue
                        }
                    }
                    else
                    {
                        print("Got unsupported Item type")
                    }
                    
                    continue
                }
                
                // Handle Timing
                let trackTimeRange = clipTimeMapping.source
                let sourceAssetTimeRange = clipTimeMapping.target
                   
                guard trackTimeRange.duration != .zero,
                      sourceAssetTimeRange.duration != .zero
                else
                {
                    continue
                }
                
                // We attempt to re-use a track per OTIO track, but we may have CMFormatDesc inconsistencies which means insertion will fails
                // If so - we make a new one  
                do
                {
                    try compositionVideoTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstVideoTrack, at: trackTimeRange.start)
                }
                catch
                {
                    if let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                    {
                        try compositionVideoTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstVideoTrack, at: trackTimeRange.start)
                    }
                }
                
                largestRasterSizeFound = CGSize(width: max(largestRasterSizeFound.width , compositionVideoTrack.naturalSize.width),
                                                height: max(largestRasterSizeFound.height , compositionVideoTrack.naturalSize.height)
                )
                
                
                // TODO: Fix - Support Time Scaling
//                let unscaledTrackTime = CMTimeRangeMake(start: trackTimeRange.start, duration: sourceAssetTimeRange.duration)
//                compositionVideoTrack.scaleTimeRange(unscaledTrackTime, toDuration: trackTimeRange.duration)
                
                // Handle source asset video natural transform for
                // ie iOS videos where camera was rotated
                let sourcePreferredTransform = try await sourceAssetFirstVideoTrack.load(.preferredTransform);
                compositionVideoTrack.preferredTransform = sourcePreferredTransform

                // Video Layer Instruction
                let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                let compositionLayerInstructions = [compositionLayerInstruction]

                // Video Composition Instruction
                let compositionVideoInstruction = AVMutableVideoCompositionInstruction()
                compositionVideoInstruction.layerInstructions = compositionLayerInstructions
                compositionVideoInstruction.timeRange = trackTimeRange
                compositionVideoInstruction.enablePostProcessing = true
                compositionVideoInstruction.backgroundColor = CGColor(gray: 0, alpha: 0)
                compositionVideoInstructions.append( compositionVideoInstruction)
            }
        }
        
        for track in self.audioTracks
        {
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

            for child in track.children
            {
                guard
                    let clip = child as? Clip,
                    let (sourceAsset, clipTimeMapping) = try clip.toAVAssetAndMapping(baseURL: baseURL, trackType: .audio, useTimecode: useAssetTimecode, rescaleToAsset: rescaleToAsset),
                    let sourceAssetFirstAudioTrack = try await sourceAsset.loadTracks(withMediaType: .audio).first,
                    let compositionAudioTrack = compositionAudioTrack
                else
                {
                    // TODO: GAP !?
                    if let gap = child as? Gap,
                       let compositionAudioTrack = compositionAudioTrack
                    {
                        do
                        {
                            let gapTimeRangeOTIO = try gap.trimmedRangeInParent() ?? gap.rangeInParent()
                            let gapTimeRange = gapTimeRangeOTIO.toCMTimeRange()
                            
                            guard
                                gapTimeRange.duration != .zero
                            else
                            {
                                continue
                            }
                            
                            compositionAudioTrack.insertEmptyTimeRange(gapTimeRange)
                            
                            let audioMixParams = AVMutableAudioMixInputParameters(track: compositionAudioTrack)

                            compositionAudioMixParams.append(audioMixParams)
                        }
                        catch
                        {
                            continue
                        }
                    }
                    continue
                }
                
                // Handle Timing
                let trackTimeRange = clipTimeMapping.source
                let sourceAssetTimeRange = clipTimeMapping.target
                
                guard trackTimeRange.duration != .zero,
                      sourceAssetTimeRange.duration != .zero
                else
                {
                    continue
                }
                
                // We attempt to re-use a track per OTIO track, but we may have CMFormatDesc inconsistencies which means insertion will fails
                // If so - we make a new one
                do
                {
                    try compositionAudioTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstAudioTrack, at: trackTimeRange.start)
                }
                catch
                {
                    if let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                    {
                        do  {
                            try compositionAudioTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstAudioTrack, at: trackTimeRange.start)
                            
                        }
                        catch {
                            print("swallowing traack insertion error \(error)")
                        }
                    }
                }
                
                // TODO: - FIX Support Time Scaling
//                let unscaledTrackTime = CMTimeRangeMake(start: trackTimeRange.start, duration: sourceAssetTimeRange.duration)
//                compositionAudioTrack.scaleTimeRange(unscaledTrackTime, toDuration: trackTimeRange.duration)
                
                // TODO: a few milliseconds fade up / fade out to avoid pops
                let audioMixParams = AVMutableAudioMixInputParameters(track: compositionAudioTrack)

                compositionAudioMixParams.append(audioMixParams)
            }
        }

        
        
        // Composition Validation
        for track in composition.tracks
        {
            if track.segments.isEmpty
            {
                composition.removeTrack(track)
            }
            
            do {
                try track.validateSegments(track.segments)
            }
            catch
            {
                throw error
            }
        }
        
        let videoComposition = try await AVMutableVideoComposition.videoComposition(withPropertiesOf: composition)
        
        // TODO: - Custom Resolution overrides?
        videoComposition.renderSize = largestRasterSizeFound //CGSize(width: 1920, height: 1080)
        videoComposition.renderScale = 1.0
        audioMix.inputParameters = compositionAudioMixParams

        // TODO: It seems as though our custom instructions occasionally have a minor time gap
        // likely due to numerical conversion precision which throws a validation error
        // Im not entirely sure what to do there!
//        videoComposition.instructions = compositionVideoInstructions
        
        // Handle custom effects (we'd need custom instructions and metadata parsing)
        if let customCompositorClass = customCompositorClass
        {
            videoComposition.customVideoCompositorClass = customCompositorClass
        }

        // Video Composition Validation
        try await videoComposition.isValid(for: composition, timeRange: CMTimeRange(start: .zero, end: composition.duration), validationDelegate:validator)

        
        return (composition:composition, videoComposition:videoComposition, audioMix:audioMix)
    }
}



