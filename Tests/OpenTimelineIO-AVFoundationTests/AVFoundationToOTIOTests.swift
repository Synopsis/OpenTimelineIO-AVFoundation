//
//  AVFoundationToOTIOTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project



import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class AVFoundationToOTIOTests: XCTestCase
{
    func testCompositionToTimeline_2398() throws
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

        let config = OTIOConversionConfig(globalStartTime: RationalTime(),
                                          urlPolicy: .fileURL,
                                          rationalTimeConversionPolicy: .passthrough,
                                          timecodePolicy: .trackTime)
        
        let timeline = try mutableComposition.toOTIOTimeline(named: "Test", config: config)

        let timelineDuration = try timeline.duration()

        XCTAssertEqual(compositionDuration.seconds, timelineDuration.toSeconds(), accuracy: Self.accuracy)

        let firstClip = timeline.videoTracks.first!.children.first as! Clip
        let firstClipDuration = try firstClip.duration()
        let firstClipSourceRange = try firstClip.rangeInParent()

        let asset1TimeRangeInComposition = CMTimeRange(start: CMTime.zero, end: CMTimeMakeWithSeconds(2.5, preferredTimescale: 23976) )
        let asset2TimeRangeInComposition = CMTimeRange(start: CMTimeMakeWithSeconds(2.5, preferredTimescale: 23976), end:CMTimeMakeWithSeconds(6.5, preferredTimescale: 23976)  )

        
        XCTAssertEqual(asset1TimeRangeInComposition.duration.seconds, firstClipDuration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(asset1TimeRangeInComposition, firstClipSourceRange.toCMTimeRange())
        XCTAssertEqual(asset1TimeRangeInComposition.toOTIOTimeRange(), firstClipSourceRange)

        let secondClip = timeline.videoTracks.first!.children[1] as! Clip
        let secondClipDuration = try secondClip.duration()
        let secondClipSourceRange = try secondClip.rangeInParent()

        XCTAssertEqual(asset2TimeRangeInComposition.duration.seconds, secondClipDuration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(asset2TimeRangeInComposition, secondClipSourceRange.toCMTimeRange())
        XCTAssertEqual(asset2TimeRangeInComposition.toOTIOTimeRange(), secondClipSourceRange)
    }
}
