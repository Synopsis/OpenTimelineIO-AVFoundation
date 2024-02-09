//
//  File.swift
//  
//
//  Created by Anton Marini on 2/7/24.
//

import Foundation
import AVFoundation
import CoreMedia
import OpenTimelineIO

// TODO:
// 1 - Asset loading is not modern async - requires some reworking of the API
// 2 - We do not support time code offsets for Asset start times - this is 'suggested' as a best practice by OTIO members
//     This would require possibly a 3rd party dependency to TimecodeKit to make things work with AVFoundation more smoothly
// 3 - Metadata for assets is not implemented yet
// 4 - Timeline's exported to OTIO work in otioviewer but dont seem to actually import in NLE's post conversion
//     It seems we are missing some best practices WRT to that
// 5 - OTIO import to a Composition
//     Basic import should be possible, however, we dont have any control over effects or composition creation in host apps
//     The infrastructure is pretty deep - ie - custom AVCompositing and custom Instructions, Metal / Core Image / CALayer based transitions, etc
//     We should discuss limitations and set expectations accordingly

// Additional Notes
// It seems to be a best practice to normalize all of our OTIO times to our assets frame rate tick
// AAF complains if our time ranges dont share the same rate
// FCPXML complains about edits not aligning to frame boundaries


public extension AVComposition
{
    func toOTIOTimeline(named name:String) throws -> Timeline
    {
        print("Making Timeline from Composition", self)
        
        let timeline = Timeline(name: name, globalStartTime: CMTime.zero.toOTIORationalTime() )

        let all_tracks:[Track] = try self.tracks.compactMap { try $0.toOTIOTrack() }

        let stack = Stack()

        try stack.set(children: all_tracks)
        
        timeline.tracks = stack
        
        return timeline
    }
}

public extension AVCompositionTrack
{
    func toOTIOTrack() throws -> Track?
    {
        var kind:Track.Kind? = nil
        
        let frameRate = Double(self.nominalFrameRate)
        let minFrameDuration = RationalTime.from(seconds: 1.0/frameRate)

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
                
        let clips = self.segments.compactMap { $0.toOTIOClip() }
        
        // Add rescaling - see Additional Notes above
        clips.forEach( {
            if let sourceRange = $0.sourceRange
            {
                let rescaledStart = sourceRange.startTime.rescaled(to: minFrameDuration)
                let rescaledDuration = sourceRange.duration.rescaled(to: minFrameDuration)
                
                $0.sourceRange = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
            }
        })
        
        // In AVAssets, tracks have time ranges at the start of the assets, and have gaps until a segment is needed
        // As opposed to OTIO, where tracks are 'inset' into the overall timeline
        // We need to manually account for the insets by finding the first
                
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
            minFrameDuration = RationalTime.from(seconds: 1.0/frameRate)
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
