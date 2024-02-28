//
//  RationalTime.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import Foundation
import CoreMedia
import OpenTimelineIO

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
        let valueDecimalPlaces = self.value.decimalPlaces()
        let rateDecimalPlaces = self.rate.decimalPlaces()
        
        let scale = pow(10.0, max(Double(rateDecimalPlaces), Double(valueDecimalPlaces)))
        let scaledValue = self.value.toTimeValue(scale)
        let scaledRate = self.rate.toTimeScale(scale)
        
        // Check for potential overflows before creating CMTime
        let maxInt32Value = Int64(Int32.max)
        let maxScaledValue = Int64(Int32.max) * Int64(scaledRate)
        
        var finalValue = scaledValue
        var finalRate = scaledRate
        
        if scaledValue > maxScaledValue
        {
            // Scaled value exceeds the maximum representable value for Int32 timescale
            finalValue = maxInt32Value
            finalRate = scaledRate * Int32(Int64(scaledValue / maxScaledValue))
        }
        
        let cmTime = CMTime(value: finalValue, timescale: Int32(finalRate))
        
        return cmTime
    }
}
