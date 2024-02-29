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
    func toOTIOTrack() throws -> Track?
    {
        var kind:Track.Kind? = nil
                
        var minFrameDuration:RationalTime? = nil

        switch (self.mediaType)
        {
        case .video:
            minFrameDuration = self.minFrameDuration.toOTIORationalTime()
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
                
        let clips = self.segments.compactMap { $0.toOTIOItem() }
                
        // We need to manually account for gaps
        let gapRanges = self.segments.compactMap( {  self.timeRange.computeMissingTimeRanges(subRange:  $0.timeMapping.target   ) }).flatMap( { $0 } )
        var gaps = gapRanges.compactMap { Gap(name:nil, sourceRange: $0.toOTIOTimeRange() ) }
        
        let clipTimeRanges = clips.map { $0.sourceRange }

        // Filter gaps that correspond to clips
        gaps = gaps.filter {  !clipTimeRanges.contains( $0.sourceRange )  }
        
        // Add rescaling (for video) - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            clips.forEach( {
                if let sourceRange = $0.sourceRange
                {
                    let rescaledStart = sourceRange.startTime.rescaled(to: minFrameDuration)
                    let rescaledDuration = sourceRange.duration.rescaled(to: minFrameDuration)
                    
                    $0.sourceRange = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
                }
            })
            
            gaps.forEach( {
                if let sourceRange = $0.sourceRange
                {
                    let rescaledStart = sourceRange.startTime.rescaled(to: minFrameDuration)
                    let rescaledDuration = sourceRange.duration.rescaled(to: minFrameDuration)
                    
                    $0.sourceRange = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
                }
            })
        }
        
       
        let trackRange = self.timeRange.toOTIOTimeRange()
        let track = Track(name:name, sourceRange:trackRange, kind: kind)
        
        try track.set(children: clips + gaps)
        
        track.tr
        
        print("Creating OTIO Track", name, "range", trackRange.startTime.toTimestring(), trackRange.endTimeExclusive().toTimestring())

        return track
    }
}

