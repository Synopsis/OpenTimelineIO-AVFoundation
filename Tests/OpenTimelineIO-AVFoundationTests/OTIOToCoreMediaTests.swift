//
//  OTIOToCoreMediaTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class OTIOToCoreMediaTests: XCTestCase 
{
    func testOTIOTimeToCMTime_Scaling_Overflow1()
    {
        let otio_time = RationalTime(value: 80747.33333333333, rate: 16000.0)

        let cm_time = otio_time.toCMTime()
        
        XCTAssertEqual(cm_time.seconds, otio_time.toSeconds(), accuracy: Self.accuracy)
    }
    
    func testOTIOTimeToCMTime_Scaling_Overflow2()
    {
        let otio_time = RationalTime(value: (104104 + 31031), rate: 24000.0)

        let cm_time = otio_time.toCMTime()
        
        XCTAssertEqual(cm_time.seconds, otio_time.toSeconds(), accuracy: Self.accuracy)
    }
    
    func testOTIOTImeToCMTime_24()
    {
        let otio_time = RationalTime(value: 18, rate: 24)

        let cm_time = otio_time.toCMTime()
        
        XCTAssertEqual(cm_time.seconds, otio_time.toSeconds())
    }
    
    func testOTIOTImeToCMTime_23_976()
    {
        let otio_time = RationalTime(value: 18 , rate: 23.976)

        let cm_time = otio_time.toCMTime()
        
        XCTAssertEqual(cm_time.seconds, otio_time.toSeconds(), accuracy: Self.accuracy)
    }
    
    func testOTIOTimeRangeToCMTimeRange_24()
    {
        let otio_timerange = TimeRange(startTime: RationalTime(value: 18, rate: 24), duration: RationalTime(value: 32, rate: 24))
        
        let cmtimerange = otio_timerange.toCMTimeRange()
        
        XCTAssertEqual(cmtimerange.start.seconds, otio_timerange.startTime.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.duration.seconds, otio_timerange.duration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.end.seconds, otio_timerange.endTimeExclusive().toSeconds(), accuracy: Self.accuracy)

        // Note - CMTimeRange end is not end time inclusive
        XCTAssertNotEqual(cmtimerange.end.seconds, otio_timerange.endTimeInclusive().toSeconds())
    }
    
    func testOTIOTimeRangeToCMTimeRange_23_976()
    {
        let otio_timerange = TimeRange(startTime: RationalTime(value: 18, rate: 23.976), duration: RationalTime(value: 32, rate: 23.976))
        
        let cmtimerange = otio_timerange.toCMTimeRange()
        
        XCTAssertEqual(cmtimerange.start.seconds, otio_timerange.startTime.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.duration.seconds, otio_timerange.duration.toSeconds(), accuracy: Self.accuracy)
        XCTAssertEqual(cmtimerange.end.seconds, otio_timerange.endTimeExclusive().toSeconds(), accuracy: Self.accuracy)

        // Note - CMTimeRange end is not end time inclusive
        XCTAssertNotEqual(cmtimerange.end.seconds, otio_timerange.endTimeInclusive().toSeconds(), accuracy: Self.accuracy)
    }
}
