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
                
        let clips = self.segments.compactMap { $0.toOTIOClip() }
        
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
        }
        
        // In AVAssets, tracks have time ranges at the start of the assets, and have gaps until a segment is needed
        // As opposed to OTIO, where tracks are 'inset' into the overall timeline (?)
        // We need to manually account for the insets by finding the first (?)
                
        let earliestClipStartTime = clips.reduce(RationalTime.from(seconds: Double.infinity ) ) { partialResult, aClip in
            
            guard
                let startTime = aClip.sourceRange?.startTime
            else
            {
                return partialResult
            }

            return (startTime < partialResult) ? startTime : partialResult
        }

        let latestEndTime = clips.reduce(RationalTime.from(seconds: 0 )) { partialResult, aClip in
            
            guard
                let endTime = aClip.sourceRange?.endTimeExclusive()
            else
            {
                return partialResult
            }
            
            return (endTime > partialResult) ? endTime : partialResult
        }

        let trackRange = TimeRange.rangeFrom(startTime: earliestClipStartTime, endTimeExclusive: latestEndTime)
        let track = Track(name:name, sourceRange:trackRange, kind: kind)
        
        try track.set(children: clips)
        
        print("Creating OTIO Track", name, "range", trackRange.startTime.toTimestring(), trackRange.endTimeExclusive().toTimestring())

        return track
    }
}
