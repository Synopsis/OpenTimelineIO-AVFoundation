//
//  DoubleTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project



import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class DoubleTests: XCTestCase
{
    func testDecimalPlaces_Nan()
    {
        let d:Double = Double.nan
        let places = 0
        
        let p = d.decimalPlaces()
        
        XCTAssertEqual(places, p)
    }
    
    func testDecimalPlaces_Inf()
    {
        let d:Double = Double.infinity
        let places = 0
        
        let p = d.decimalPlaces()
        
        XCTAssertEqual(places, p)
    }
    
    func testDecimalPlaces_FromInt()
    {
        let d:Double = Double(integerLiteral: 1)
        let places = 1
        
        let p = d.decimalPlaces()
        
        XCTAssertEqual(places, p)
    }
    
    func testDecimalPlaces4()
    {
        let d = 0.0001
        let places = 4
        
        let p = d.decimalPlaces()
        
        XCTAssertEqual(places, p)
    }
    
    func testDecimalPlaces_23967()
    {
        let d = 24000.0/1001.0
        let places = 15
        
        let p = d.decimalPlaces()
        
        XCTAssertEqual(places, p)
    }
    
}
