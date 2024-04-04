//
//  Double.swift
//  
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import Foundation
import CoreMedia

// Since OpenTimelineIO represents Rational Time using a pair of Doubles
// We find ourself in a case where conversion to CMTimeScale CMTimeValue
// Could be lossy if naively implemented
// Thus, we check if a lossless conversion can happen
// If not, we find the multiplier to make it an int

public extension Double
{
    // Until we have access to this from OTIO Swift Brige
    // We copy these structs from rationalTime.cpp / opentime
    static let dropframeTimecodeRates:[Double] = [29.97,
                                          30000.0 / 1001.0,
                                          59.94,
                                          60000.0 / 1001.0]
    
    static let smpteTimecodeRates:[Double] = [1.0,
                                               12.0,
                                               24000.0 / 1001.0,
                                               24.0,
                                               25.0,
                                               30000.0 / 1001.0,
                                               30.0,
                                               48.0,
                                               50.0,
                                               60000.0 / 1001.0,
                                               60.0]
    
    static let validTimecodeRates:[Double] = [1.0,
                                               12.0,
                                               23.97,
                                               23.976,
                                               23.98,
                                               24000.0 / 1001.0,
                                               24.0,
                                               25.0,
                                               29.97,
                                               30000.0 / 1001.0,
                                               30.0,
                                               48.0,
                                               50.0,
                                               59.94,
                                               60000.0 / 1001.0,
                                               60.0 ]
    
    func decimalPlaces() -> Int
    {
        let numberString = String(self)
        
        // Check if the string representation contains a decimal point
        guard 
            let decimalRange = numberString.range(of: ".")
        else
        {
            // No decimal point found, so the number has 0 decimal places
            return 0
        }
        
        // Calculate the number of decimal places
        let fractionalPart = numberString.suffix(from: decimalRange.upperBound)
        return fractionalPart.count
    }
    
    
    func toTimeScale(_ scale:Double = 1.0) -> CMTimeScale
    {
        return CMTimeScale( Int32(self * scale) )
    }
    
    func toTimeValue(_ scale:Double = 1.0) -> CMTimeValue
    {
        return CMTimeValue( Int64(self * scale) )
    }
    
    func closestValueIn(_ array: [Double]) -> Double? 
    {
        guard !array.isEmpty else { return nil }

        let closestValue = array.reduce(array[0]) { (closest, current) in
            let closestDifference = abs(self - closest)
            let currentDifference = abs(self - current)
            return closestDifference < currentDifference ? closest : current
        }

        return closestValue

    }
}
