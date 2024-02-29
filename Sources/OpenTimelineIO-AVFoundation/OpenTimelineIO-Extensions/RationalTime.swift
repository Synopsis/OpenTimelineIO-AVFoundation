//
//  RationalTime.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import Foundation
import CoreMedia
import OpenTimelineIO
import TimecodeKit

public extension RationalTime
{
//    func toCMTime() -> CMTime
//    {
//        let valueDecimalPlaces = self.value.decimalPlaces() 
//        let rateDecimalPlaces = self.rate.decimalPlaces()
//                
//        let places = min( max( Double(rateDecimalPlaces), Double(valueDecimalPlaces)), 9)
//        let scale = pow(10.0,  places) 
//        let scaledValue = self.value.toTimeValue( scale )
//        let scaledRate = self.rate.toTimeScale( scale )
//
//        let cmTime = CMTime(value: scaledValue, timescale: scaledRate)
//        
//        return cmTime
//    }
    
    func toCMTime() -> CMTime
    {
//        we need to figure out why we get a tiny fractional offset with the ava Material
//        we get a gap between 5.630624999 and 5.630625
//        maybe look into minFrameDuration timing on Clip to asset ?
        let nsnumber:NSNumber = NSNumber(floatLiteral: self.value / self.rate )
        let double = Double(truncating: nsnumber)
        let timecodeKitFraction = Fraction(double: double, decimalPrecision:9)
        
        return timecodeKitFraction.cmTimeValue
    }
}
