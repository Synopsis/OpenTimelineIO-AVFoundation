//
//  File.swift
//  
//
//  Created by Anton Marini on 2/9/24.
//

import Foundation
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
    
    func toAVCompositionRenderables() -> (composition:AVComposition, videoComposition:AVVideoComposition, audioMix:AVAudioMix)?
    {
        let options =  [AVURLAssetPreferPreciseDurationAndTimingKey : true] as [String : Any]

        let composition = AVMutableComposition(urlAssetInitializationOptions: options)
        
        let audioMix = AVMutableAudioMix()
        var audioMixParams = [AVAudioMixInputParameters]()

        var compositionVideoInstructions = [AVVideoCompositionInstruction]()

        for track in self.videoTracks
        {
            for child in track.children
            {
                guard
                    let clip = child as? Clip,
                    let (asset, timeMapping) = clip.toAVAssetAndMapping(),
                    let firstAssetVideoTrack = asset.tracks(withMediaType: .video).first
                else
                {
                    // TODO: GAP !?
                    continue
                }
                
                // the target track we will edit into
                // Note this has no relation to our OTIO Track
                let compositionVideoTrack = composition.mutableTrack(compatibleWith: firstAssetVideoTrack) ?? composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                
                let compositionVideoInstruction = AVMutableVideoCompositionInstruction()
                compositionVideoInstruction.timeRange = segmentTimeRange
                compositionVideoInstruction.enablePostProcessing = false

                compositionVideoInstruction.backgroundColor = NSColor.black.cgColor
                
    //            let rec709CSpace = NSColorSpace(cgColorSpace: CGColorSpace(name: CGColorSpace.itur_709) ) ?? NSColorSpace.sRGB
    //            compositionVideoInstruction.backgroundColor = NSColor(colorSpace: rec709CSpace, hue:0, saturation: 0, brightness: 0, alpha: 0).cgColor
                
                var requiredSourceTrackIDs = [CMPersistentTrackID]()
                var layerInstructions = [AVVideoCompositionLayerInstruction]()
                
                
            }
        }
    }
}
