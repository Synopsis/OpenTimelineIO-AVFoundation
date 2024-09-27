//
//  AVCompositionTrack.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import Foundation
import AVFoundation
import CoreMedia
import OpenTimelineIO
import TimecodeKit

public extension AVCompositionTrack
{
    func toOTIOTrack(config:OTIOConversionConfig) throws -> Track?
    {
        var kind:Track.Kind? = nil
                
        switch (self.mediaType)
        {
        case .video:
            kind = .video
            
        case .audio:
            kind = Track.Kind.audion
        default:
            break
        }
        
        guard
            let kind = kind
        else
        {
            return nil
        }
        
        let name = String(format: "Track %i", self.trackID)
                
        let clips = self.segments.compactMap { $0.toOTIOItem(config:config) }
                
        // We need to manually account for gaps
        let clipTimeRanges = clips.compactMap { do { return try $0.rangeInParent().toCMTimeRange() } catch { return nil } }

        let gapRanges = self.timeRange.computeGapsOf(subranges: clipTimeRanges)
        let gaps = gapRanges.compactMap { Gap(name:nil, sourceRange: $0.toOTIOTimeRange() ) }

        
        // MARK: - Time Conversion Policy
        var trackRange = self.timeRange.toOTIOTimeRange()

        // Add rescaling (for video) - see Additional Notes above
        let minFrameDuration = self.minFrameDuration.toOTIORationalTime()
        
        trackRange = config.rationalTimeConversionPolicy.convert(trackRange, targetRate: minFrameDuration)
        
        clips.forEach( {
            if let sourceRange = $0.sourceRange
            {
                $0.sourceRange = config.rationalTimeConversionPolicy.convert(sourceRange, targetRate: minFrameDuration)
            }
        })
        
        gaps.forEach( {
            if let sourceRange = $0.sourceRange
            {
                $0.sourceRange = config.rationalTimeConversionPolicy.convert(sourceRange, targetRate: minFrameDuration)
            }
        })
       
        // MARK: -
       
        let track = Track(name:name, sourceRange:trackRange, kind: kind)
        
        try track.set(children: clips )
                
        print("Creating OTIO Track", name, "range", trackRange.startTime.toTimestring(), trackRange.endTimeExclusive().toTimestring())

        return track
    }
}

