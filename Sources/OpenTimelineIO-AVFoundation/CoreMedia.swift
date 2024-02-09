//
//  CoreMedia.swift
//  
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import Foundation
import CoreMedia
import OpenTimelineIO

public extension RationalTime
{
    func toCMTime() -> CMTime 
    {
        let valueDecimalPlaces = self.value.decimalPlaces()
        let rateDecimalPlaces = self.rate.decimalPlaces()
                
        let scale = pow(10.0, max( Double(rateDecimalPlaces), Double(valueDecimalPlaces) ) )
        let scaledValue = self.value.toTimeValue( scale )
        let scaledRate = self.rate.toTimeScale( scale )

        let cmTime = CMTime(value: scaledValue, timescale: scaledRate)
        
        return cmTime
    }
}

public extension CMTime
{
    func toOTIORationalTime() -> RationalTime
    {
        return RationalTime(value: Double( self.value ), rate: Double( self.timescale ) )
    }
}

public extension TimeRange
{
    func toCMTimeRange() -> CMTimeRange
    {
        return CMTimeRange(start: self.startTime.toCMTime(), duration: self.duration.toCMTime() )
    }
}

public extension CMTimeRange
{
    func toOTIOTimeRange() -> TimeRange
    {
        return TimeRange(startTime: self.start.toOTIORationalTime(), duration: self.duration.toOTIORationalTime() )
    }
}
