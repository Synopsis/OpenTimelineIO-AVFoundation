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
//        let scale = pow(10.0, max( Double(rateDecimalPlaces), Double(valueDecimalPlaces) ) )
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
        
        let timecodeKitFraction = Fraction(double: self.toSeconds(), decimalPrecision:9)
        
        return timecodeKitFraction.cmTimeValue
    }
}
