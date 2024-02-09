//
//  testCoreMediaExtensions.swift
//  
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import XCTest
@testable import OpenTimelineIO

import Foundation
import CoreMedia

class testCoreMediaExtensions: XCTestCase {
        
    // When dealing with non int rates, we suffer from some floating point precision
    // Compared to Int64 Rational match in CMTime
    // In these cases, we check our our accuracy

    static let accuracy = 0.00000000001
    
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
    
    func testOTIOTimeRangeToCMTimeRange_24()
    {
        let otio_timerange = TimeRange(startTime: RationalTime(value: 18, rate: 24), duration: RationalTime(value: 32, rate: 24))
        
        let cmtimerange = otio_timerange.toCMTimeRange()
        
        XCTAssertEqual(cmtimerange.start.seconds, otio_timerange.startTime.toSeconds())
        XCTAssertEqual(cmtimerange.duration.seconds, otio_timerange.duration.toSeconds())
        XCTAssertEqual(cmtimerange.end.seconds, otio_timerange.endTimeExclusive().toSeconds())

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
