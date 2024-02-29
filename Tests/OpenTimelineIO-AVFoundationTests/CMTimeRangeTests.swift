//  CMTimeRangeTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class CMTimeRangeTests: XCTestCase {
    
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
    
    func testCMTImeRangeGaps2()
    {
        // Example usage
        let fullRange = CMTimeRange(start: CMTime.zero, duration: CMTime.init(seconds: 10, preferredTimescale: 600))
        let subRange1 = CMTimeRange(start: CMTime.init(seconds: 2, preferredTimescale: 600), duration: CMTime.init(seconds: 1, preferredTimescale: 600))

        let subRange2 = CMTimeRange(start: CMTime.init(seconds: 4, preferredTimescale: 600), duration: CMTime.init(seconds: 1, preferredTimescale: 600))
        
        // No Gap
        let subRange3 = CMTimeRange(start: CMTime.init(seconds: 5, preferredTimescale: 600), duration: CMTime.init(seconds: 1, preferredTimescale: 600))

        let missingRanges = fullRange.computeGapsOf(subranges: [subRange1, subRange2, subRange3])
        
        let firstMissingRange = CMTimeRange(start: CMTime.zero, end: CMTime.init(seconds: 2, preferredTimescale: 600) )
        
        let secondMissingRange = CMTimeRange(start: CMTime.init(seconds: 3, preferredTimescale: 600), end: CMTime.init(seconds: 4, preferredTimescale: 600) )
        
        let thirdMissingRange = CMTimeRange(start: CMTime.init(seconds: 6, preferredTimescale: 600), end: CMTime.init(seconds: 10, preferredTimescale: 600) )

        XCTAssertEqual(missingRanges, [firstMissingRange, secondMissingRange, thirdMissingRange] )
        
        print(missingRanges)
    }
    
    func testCMTImeRangeNoGaps()
    {
        // Example usage
        let fullRange = CMTimeRange(start: CMTime.zero, duration: CMTime.init(seconds: 10, preferredTimescale: 600))
        
        let subRange1 = CMTimeRange(start: CMTime.init(seconds: 0, preferredTimescale: 600), end: CMTime.init(seconds: 1, preferredTimescale: 600))

        let subRange2 = CMTimeRange(start: CMTime.init(seconds: 1, preferredTimescale: 600), end: CMTime.init(seconds: 3, preferredTimescale: 600))

        let subRange3 = CMTimeRange(start: CMTime.init(seconds: 3, preferredTimescale: 600), end: CMTime.init(seconds: 7, preferredTimescale: 600))
        
        let subRange4 = CMTimeRange(start: CMTime.init(seconds: 7, preferredTimescale: 600), end: CMTime.init(seconds:9.5 , preferredTimescale: 600))

        let subRange5 = CMTimeRange(start: CMTime.init(seconds: 9.5, preferredTimescale: 600), end: CMTime.init(seconds:10 , preferredTimescale: 600))

        let missingRanges = fullRange.computeGapsOf(subranges: [subRange1, subRange2, subRange3, subRange4, subRange5])
        
        XCTAssertEqual(missingRanges.isEmpty, true )
        
        print(missingRanges)
    }
}
