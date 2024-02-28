//
//  Timeline.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import AppKit
import CoreMedia
import AVFoundation
import OpenTimelineIO

public extension Timeline
{
    
    // Some running notes about this conversion
    
    // 1 - Tracks
    // In a mutable composition, tracks must have compatible CMFormatDescriptions for different assets to be inserted
    // This is not like the more abstract representation of tracks in OTIO, where any external reference can follow any other in a nice fasion
    // So we cannot 1:1 make an AVCompositionTrack for every OTIO Track. We may have one to many, depending on underlying asset format descriptions
    // So here, we effectively ignore OTIO tracks and use the assets to see if we have compatible tracks.
    // If we do - great. if we dont, we make a new one.
    
    func toAVCompositionRenderables(baseURL:URL? = nil, customCompositorClass:AVVideoCompositing.Type? = nil) async throws -> (composition:AVComposition, videoComposition:AVVideoComposition, audioMix:AVAudioMix)?
    {
        // Get our global offset - if we have one, to normalize track times
        let globalStartCMTime = self.globalStartTime?.toCMTime()
        
        let options =  [AVURLAssetPreferPreciseDurationAndTimingKey : true] as [String : Any]

        let composition = AVMutableComposition(urlAssetInitializationOptions: options)
        let audioMix = AVMutableAudioMix()

        // All rendering instructions for our tracks / segments 
        var compositionVideoInstructions = [AVVideoCompositionInstruction]()
        var compositionAudioMixParams = [AVAudioMixInputParameters]()

        for track in self.videoTracks
        {
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)

            let transitions:[Transition] = track.children.compactMap( { guard let transition = $0 as? Transition else { return nil }; return transition })
            let clips:[Clip] = track.children.compactMap( { guard let clip = $0 as? Clip else { return nil }; return clip })

            for clip in clips
            {
                guard
                    let (sourceAsset, clipTimeMapping) = try clip.toAVAssetAndMapping(baseURL: baseURL),
                    let sourceAssetFirstVideoTrack = try await sourceAsset.loadTracks(withMediaType: .video).first,
                    let compositionVideoTrack = compositionVideoTrack //composition.mutableTrack(compatibleWith: sourceAssetFirstVideoTrack) ??
                else
                {
                    // TODO: GAP !?
                    continue
                }
                
                // Handle Timing
                let trackTimeRange = clipTimeMapping.target
                let sourceAssetTimeRange = clipTimeMapping.source
                   
                // We attempt to re-use a track per OTIO track, but we may have CMFormatDesc inconsistencies which means insertion will fails
                // If so - we make a new one
                do
                {
                    try compositionVideoTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstVideoTrack, at: trackTimeRange.start)
                }
                catch
                {
                    if let compositionVideoTrack = composition.mutableTrack(compatibleWith: sourceAssetFirstVideoTrack) ?? composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                    {
                        try compositionVideoTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstVideoTrack, at: trackTimeRange.start)
                    }
                }
                
                // Support Time Scaling
                let unscaledTrackTime = CMTimeRangeMake(start: trackTimeRange.start, duration: sourceAssetTimeRange.duration)
                compositionVideoTrack.scaleTimeRange(unscaledTrackTime, toDuration: trackTimeRange.duration)
                
                // Handle source asset video natural transform for
                // ie iOS videos where camera was rotated
                let sourcePreferredTransform = try await sourceAssetFirstVideoTrack.load(.preferredTransform);
                compositionVideoTrack.preferredTransform = sourcePreferredTransform

                // Video Layer Instruction
                let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                compositionLayerInstruction.setOpacity(0.5, at: unscaledTrackTime.start)
                let compositionLayerInstructions = [compositionLayerInstruction]

                // Video Composition Instruction
                let compositionVideoInstruction = AVMutableVideoCompositionInstruction()
                compositionVideoInstruction.layerInstructions = compositionLayerInstructions
                compositionVideoInstruction.timeRange = trackTimeRange
                compositionVideoInstruction.enablePostProcessing = false
                compositionVideoInstruction.backgroundColor = NSColor.black.cgColor
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
                    let (sourceAsset, clipTimeMapping) = try clip.toAVAssetAndMapping(baseURL: baseURL),
                    let sourceAssetFirstAudioTrack = try await sourceAsset.loadTracks(withMediaType: .audio).first,
                    let compositionAudioTrack = compositionAudioTrack
                else
                {
                    // TODO: GAP !?
                    continue
                }
                
                // Handle Timing
                let trackTimeRange = clipTimeMapping.target
                let sourceAssetTimeRange = clipTimeMapping.source
                
                // We attempt to re-use a track per OTIO track, but we may have CMFormatDesc inconsistencies which means insertion will fails
                // If so - we make a new one
                do
                {
                    try compositionAudioTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstAudioTrack, at: trackTimeRange.start)
                }
                catch
                {
                    if let compositionAudioTrack = composition.mutableTrack(compatibleWith: sourceAssetFirstAudioTrack) ?? composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                    {
                        try compositionAudioTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstAudioTrack, at: trackTimeRange.start)
                    }
                }
                
                compositionAudioTrack.isEnabled = try await sourceAssetFirstAudioTrack.load(.isEnabled)

                // TODO: a few milliseconds fade up / fade out to avoid pops
                let audioMixParams = AVMutableAudioMixInputParameters(track: compositionAudioTrack)

                compositionAudioMixParams.append(audioMixParams)
            }
        }
        
        // Composition Validation
        for track in composition.tracks
        {
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
        // videoComposition.renderSize = CGSize(width: 1920, height: 1080)
        videoComposition.renderScale = 1.0
        videoComposition.instructions = compositionVideoInstructions
        
        // Handle custom effects (we'd need custom instructions and metadata parsing)
        if let customCompositorClass = customCompositorClass
        {
            videoComposition.customVideoCompositorClass = customCompositorClass
        }

        // Rec 709 by default
        videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2;
        videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2;
        videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2;

        // Video Composition Validation
        try await videoComposition.isValid(for: composition, timeRange: CMTimeRange(start: .zero, end: composition.duration), validationDelegate:self)

        audioMix.inputParameters = compositionAudioMixParams

        
        return (composition:composition, videoComposition:videoComposition, audioMix:audioMix)

    }
}


extension Timeline : AVVideoCompositionValidationHandling
{
    public func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidValueForKey key: String) -> Bool
    {
        return false
    }
    
    public func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingEmptyTimeRange timeRange: CMTimeRange) -> Bool
    {
        return false
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
