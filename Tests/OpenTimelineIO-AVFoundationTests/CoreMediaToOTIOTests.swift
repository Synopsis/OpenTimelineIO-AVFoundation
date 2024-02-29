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
}
