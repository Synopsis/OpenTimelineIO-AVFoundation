//
//  DoubleTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project



import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import TimecodeKit

class FractionTests: XCTestCase
{
    func testNormalizeTo1()
    {
        let frac = Fraction(1000, 24000)
        
        let renormalized = frac.normalizeTo(targetDenominator: 24)
        
        XCTAssertEqual(24, renormalized.denominator)
        XCTAssertEqual(1, renormalized.numerator)
    }
    
    func testNormalizeTo2()
    {
        let frac = Fraction(1, 24)
        
        let renormalized = frac.normalizeTo(targetDenominator: 24000)
        
        XCTAssertEqual(24000, renormalized.denominator)
        XCTAssertEqual(1000, renormalized.numerator)
    }
   
}
