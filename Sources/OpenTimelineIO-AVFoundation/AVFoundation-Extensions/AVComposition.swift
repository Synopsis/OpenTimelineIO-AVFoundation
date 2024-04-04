//
//  AVComposition.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

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
    func toOTIOTimeline(named name:String, config:OTIOConversionConfig) throws -> Timeline
    {
        print("Making Timeline from Composition", self)
        
        let timeline = Timeline(name: name, globalStartTime: config.globalStartTime )

        let all_tracks:[Track] = try self.tracks.compactMap { try $0.toOTIOTrack(config: config) }

        let stack = Stack()

        try stack.set(children: all_tracks)
        
        timeline.tracks = stack
        
        return timeline
    }
}
