//
//  File.swift
//  
//
//  Created by Anton Marini on 2/9/24.
//

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
    
    func toAVCompositionRenderables(customCompositorClass:AVVideoCompositing.Type? = nil) async throws -> (composition:AVComposition, videoComposition:AVVideoComposition, audioMix:AVAudioMix)?
    {
        let options =  [AVURLAssetPreferPreciseDurationAndTimingKey : true] as [String : Any]

        let composition = AVMutableComposition(urlAssetInitializationOptions: options)
        let audioMix = AVMutableAudioMix()
        var audioMixParams = [AVAudioMixInputParameters]()

        // All rendering instructions for our tracks / segments
        var compositionVideoInstructions = [AVVideoCompositionInstruction]()

        for track in self.videoTracks
        {
            for child in track.children
            {
                guard
                    let clip = child as? Clip,
                    let (sourceAsset, clipTimeMapping) = try clip.toAVAssetAndMapping(),
                    let sourceAssetFirstVideoTrack = try await sourceAsset.loadTracks(withMediaType: .video).first,
                    let compositionVideoTrack = composition.mutableTrack(compatibleWith: sourceAssetFirstVideoTrack) ?? composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                else
                {
                    // TODO: GAP !?
                    continue
                }
                
                // Handle Timing
                let trackTimeRange = clipTimeMapping.target
                let sourceAssetTimeRange = clipTimeMapping.source
                try compositionVideoTrack.insertTimeRange(sourceAssetTimeRange, of: sourceAssetFirstVideoTrack, at: trackTimeRange.start)
                
                // Support Time Scaling
                let unscaledTrackTime = CMTimeRangeMake(start: trackTimeRange.start, duration: sourceAssetTimeRange.duration)
                compositionVideoTrack.scaleTimeRange(unscaledTrackTime, toDuration: trackTimeRange.duration)
                
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
                compositionVideoInstruction.enablePostProcessing = false
                compositionVideoInstruction.backgroundColor = NSColor.black.cgColor
                
                compositionVideoInstructions.append( compositionVideoInstruction)
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

        audioMix.inputParameters = audioMixParams
        
        return (composition:composition, videoComposition:videoComposition, audioMix:audioMix)

    }
}
