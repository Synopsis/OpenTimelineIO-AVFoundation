//
//  AVCompositionTrackSegment.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import Foundation
import AVFoundation
import CoreMedia
import OpenTimelineIO

public extension AVCompositionTrackSegment
{
    func toOTIOItem(rescaleToAsset:Bool = true) -> Item?
    {
        if self.isEmpty
        {
            return Gap(name:nil, sourceRange: self.timeMapping.target.toOTIOTimeRange())
        }
        
        guard
            let sourceURL = self.sourceURL
        else
        {
            return nil
        }
        
        let name = sourceURL.absoluteURL.path()
        
        let asset = AVURLAsset(url: sourceURL)
        

        var minFrameDuration:RationalTime? = nil
        
        if let sourceTrack = asset.track(withTrackID: self.sourceTrackID),
           rescaleToAsset
        {
            // Audio has invalid minFrameDuration
            if sourceTrack.minFrameDuration.isValid
            {
                minFrameDuration = sourceTrack.minFrameDuration.toOTIORationalTime()
            }
        }
        
        
        var referenceRange = self.timeMapping.source.toOTIOTimeRange()
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = referenceRange.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = referenceRange.duration.rescaled(to: minFrameDuration)
            
            referenceRange = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        let externalReference = ExternalReference(targetURL: sourceURL.standardizedFileURL.absoluteString, availableRange:referenceRange )
        print("Creating OTIO External Reference", name, "externalReferenceRange", referenceRange.startTime.toTimestring(), referenceRange.endTimeExclusive().toTimestring())
        
        var clipRange = self.timeMapping.target.toOTIOTimeRange()
        
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
