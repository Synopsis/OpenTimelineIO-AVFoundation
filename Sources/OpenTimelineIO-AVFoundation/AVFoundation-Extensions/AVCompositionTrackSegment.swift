//
//  AVCompositionTrackSegment.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import Foundation
import AVFoundation
import CoreMedia
import OpenTimelineIO
import TimecodeKit

public extension AVCompositionTrackSegment
{
    func toOTIOItem(config:OTIOConversionConfig) -> Item?
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
        
        let name = sourceURL.lastPathComponent
        
        let asset = AVURLAsset(url: sourceURL)
        
        let externalReference = asset.toOTIOExternalReference(config: config)
        
        print("Creating OTIO External Reference", name, "externalReferenceRange", externalReference.availableRange?.startTime.toTimestring(), externalReference.availableRange?.endTimeExclusive().toTimestring())
        
        // MARK: - TimeCode Policy
        var clipRange = self.timeMapping.source

        switch config.timecodePolicy
        {
        case .timecode:
                do
                {
                    if let timecode = try asset.startTimecode()
                    {
                        clipRange = CMTimeRange(start:clipRange.start + timecode.cmTimeValue, duration: clipRange.duration)
                    }
                }
                catch
                {
                    // no - op
                }
            break
        case .trackTime:
            break
        }
        
        var clipRangeRational = clipRange.toOTIOTimeRange()

        // MARK: - Time Conversion Policy

        // Add rescaling - see Additional Notes above
        if let firstMinFrameDuration = asset.readMinFrameDurations().first
        {
            let rescaledStart = clipRangeRational.startTime.rescaled(to: firstMinFrameDuration.toOTIORationalTime())
            let rescaledDuration = clipRangeRational.duration.rescaled(to: firstMinFrameDuration.toOTIORationalTime())
            
            clipRangeRational = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        let clip = Clip(name: name, mediaReference: externalReference, sourceRange: clipRangeRational)
        
        print("Creating OTIO Clip", name, "sourceRange", clipRangeRational.startTime.toTimestring(), clipRangeRational.endTimeExclusive().toTimestring())
        
        return clip
    }
}
