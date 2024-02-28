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
}
