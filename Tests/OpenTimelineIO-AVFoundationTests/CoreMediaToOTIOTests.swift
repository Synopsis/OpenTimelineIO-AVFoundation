//
//  CoreMediaToOTIOTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class CoreMediaToOTIOTests: XCTestCase {
                
    func testCMTImeRangeGaps()
    {
        // Example usage
        let fullRange = CMTimeRange(start: CMTime.zero, duration: CMTime.init(seconds: 10, preferredTimescale: 600))
        let subRange = CMTimeRange(start: CMTime.init(seconds: 2, preferredTimescale: 600), duration: CMTime.init(seconds: 4, preferredTimescale: 600))

        let missingRanges = fullRange.computeGapsOf(subranges: [subRange])
//        let missingRanges = fullRange.computeMissingTimeRanges(subRange: subRange)
        
        let firstMissingRange = CMTimeRange(start: CMTime.zero, end: CMTime.init(seconds: 2, preferredTimescale: 600) )
        let secondMissingRange = CMTimeRange(start: CMTime.init(seconds: 6, preferredTimescale: 600), end: CMTime.init(seconds: 10, preferredTimescale: 600) )

        XCTAssertEqual(missingRanges, [firstMissingRange, secondMissingRange] )

        print(missingRanges)
    }
    

    
    func testCMTimeToOTIOTime_24()
    {
        let cm_time = CMTime(value: 18, timescale: 24)

        let otio_time = cm_time.toOTIORationalTime()
        
        XCTAssertEqual(cm_time.seconds, otio_time.toSeconds())
    }
    
    func testCMTimeToOTIOTime_23_976()
    {
        let cm_time = CMTime(value: 18000, timescale: 23976)

        let otio_time = cm_time.toOTIORationalTime()
        
        XCTAssertEqual(cm_time.seconds, otio_time.toSeconds(), accuracy: Self.accuracy)
    }
        
    func testCompositionToTimeline() throws
    {
        let thisFile = URL(filePath: #file)
        let testAsset1URL = thisFile.deletingLastPathComponent().appending(component: "Assets/OTIO Test Media 1 - 23.98.mp4")
        let testAsset2URL = thisFile.deletingLastPathComponent().appending(component: "Assets/OTIO Test Media 2 - 23.98.mp4")

        let asset1 = AVURLAsset(url: testAsset1URL)
        let asset2 = AVURLAsset(url: testAsset2URL)
        
        let mutableComposition = AVMutableComposition()
        
        let asset1TimeRange = CMTimeRange(start: CMTime.zero, end: CMTimeMakeWithSeconds(2.5, preferredTimescale: 23976) )
        let asset2TimeRange = CMTimeRange(start: CMTimeMakeWithSeconds(3.5, preferredTimescale: 23976), end: CMTimeMakeWithSeconds(7.5, preferredTimescale: 23976) )

        try mutableComposition.insertTimeRange(asset1TimeRange, of: asset1, at: CMTime.zero)

        try mutableComposition.insertTimeRange(asset2TimeRange, of: asset2, at: CMTimeRangeGetEnd(asset1TimeRange) )
        
        let compositionDuration = mutableComposition.duration

        let timeline = try mutableComposition.toOTIOTimeline(named: "Test")

        let timelineDuration = try timeline.duration()

        XCTAssertEqual(compositionDuration.seconds, timelineDuration.toSeconds(), accuracy: Self.accuracy)

        let firstClip = timeline.videoTracks.first!.children.first as! Clip
        let firstClipDuration = try firstClip.duration()
        let firstClipSourceRange = firstClip.sourceRange
        
        XCTAssertEqual(asset1TimeRange.duration.seconds, firstClipDuration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(asset1TimeRange, firstClipSourceRange?.toCMTimeRange())
        XCTAssertEqual(asset1TimeRange.toOTIOTimeRange(), firstClipSourceRange)

        let secondClip = timeline.videoTracks.first!.children[1] as! Clip
        let secondClipDuration = try secondClip.duration()
        let secondClipSourceRange = secondClip.sourceRange

        XCTAssertEqual(asset2TimeRange.duration.seconds, secondClipDuration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(asset2TimeRange, secondClipSourceRange?.toCMTimeRange())
        XCTAssertEqual(asset2TimeRange.toOTIOTimeRange(), secondClipSourceRange)
    }
    
    func testTimelineToComposition() async throws
    {
        let thisFile = URL(filePath: #file)
        let timelineURL = thisFile.deletingLastPathComponent().appending(component: "Assets/Timeline_23.98.otio")
        let timeline = try Timeline.fromJSON(url:timelineURL) as! Timeline

        let (composition, _, _) = try await timeline.toAVCompositionRenderables(baseURL: timelineURL.deletingLastPathComponent() )!

        let compositionDuration = composition.duration

        let timelineDuration = try timeline.duration()

        XCTAssertEqual(compositionDuration.seconds, timelineDuration.toSeconds(), accuracy: Self.accuracy)        
    }
}
