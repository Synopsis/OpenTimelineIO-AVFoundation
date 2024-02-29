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
    
    func testCMTimeRangeToOTIOTimeRange_24()
    {
        let cmtimerange =  CMTimeRange(start: CMTime(value: 18, timescale: 24), duration: CMTime(value: 32, timescale: 24))
        let otio_timerange = cmtimerange.toOTIOTimeRange()
        
        XCTAssertEqual(cmtimerange.start.seconds, otio_timerange.startTime.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.duration.seconds, otio_timerange.duration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.end.seconds, otio_timerange.endTimeExclusive().toSeconds(), accuracy: Self.accuracy)

        // Note - CMTimeRange end is not end time inclusive
        XCTAssertNotEqual(cmtimerange.end.seconds, otio_timerange.endTimeInclusive().toSeconds())
    }
    
    func testCMTimeRangeToOTIOTimeRange_23_976()
    {
        let cmtimerange =  CMTimeRange(start: CMTime(value: 18000, timescale: 23976), duration: CMTime(value: 32000, timescale: 23976))
        let otio_timerange = cmtimerange.toOTIOTimeRange()

        XCTAssertEqual(cmtimerange.start.seconds, otio_timerange.startTime.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.duration.seconds, otio_timerange.duration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.end.seconds, otio_timerange.endTimeExclusive().toSeconds(), accuracy: Self.accuracy)

        // Note - CMTimeRange end is not end time inclusive
        XCTAssertNotEqual(cmtimerange.end.seconds, otio_timerange.endTimeInclusive().toSeconds(), accuracy: Self.accuracy)
    }
}
