//
//  File.swift
//  
//
//  Created by Anton Marini on 2/9/24.
//

import Foundation
import AVFoundation
import CoreMedia
import OpenTimelineIO

public extension AVCompositionTrackSegment
{
    func toOTIOClip() -> Clip?
    {
        guard
            let sourceURL = self.sourceURL
        else
        {
            return nil
        }
        
        let name = sourceURL.lastPathComponent
        
        let asset = AVURLAsset(url: sourceURL)
        
        let duration = asset.duration.toOTIORationalTime()

        // It seems to be a best practice to normalize all of our OTIO times to our assets frame rate tick
        // AAF complains if our time ranges dont share the same rate
        var minFrameDuration:RationalTime? = nil
        
        if let firstVideoTrack = asset.tracks(withMediaType: .video).first
        {
            let frameRate = Double(firstVideoTrack.nominalFrameRate)
//            minFrameDuration = RationalTime.from(seconds: 1.0/frameRate)
            let minFrameDuration = RationalTime(value: 1.0, rate: frameRate)
        }
        
        let start = RationalTime(value:0, rate:duration.rate)
        var referenceRange = TimeRange(startTime: start, duration: duration)
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = referenceRange.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = referenceRange.duration.rescaled(to: minFrameDuration)
            
            referenceRange = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        let externalReference = ExternalReference(targetURL: sourceURL.standardizedFileURL.absoluteString, availableRange:referenceRange )
        print("Creating OTIO External Reference", name, "externalReferenceRange", referenceRange.startTime.toTimestring(), referenceRange.endTimeExclusive().toTimestring())
        
        var clipRange = self.timeMapping.source.toOTIOTimeRange()
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = clipRange.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = clipRange.duration.rescaled(to: minFrameDuration)
            
            clipRange = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        let clip = Clip(name: name, mediaReference: externalReference, sourceRange: clipRange)
        
        print("Creating OTIO Clip", name, "sourceRange", clipRange.startTime.toTimestring(), clipRange.endTimeExclusive().toTimestring())
        
        return clip
    }
}
