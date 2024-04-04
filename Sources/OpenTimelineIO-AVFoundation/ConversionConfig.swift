//
//  File.swift
//  
//
//  Created by Anton Marini on 4/4/24.
//

import OpenTimelineIO

public struct OTIOConversionConfig
{
    // How do we convert handle paths
    // OTIO does not specify.. :(
    public enum URLPolicy
    {
        case fileURL
        case absolutePath
        case relativePath(root:String)
    }
    
    // How do we convert our CMTime or Rational Times
    public enum RationalTimeConversionPolicy
    {
        // Convert CMTimes to RationalTime as with as minimal loss as possible.
        // Dtay true to the containers reported value and time base
        case passthrough

        // Convert CMTimes To Rational Times and normalize to the assets nominal framerate
        case assetNominalFrameRate
        
        // Here we re-normalize our Rational Times to have well known rates
        case nearestSMTPERate
        
        
        func convert(_ rationalTime:RationalTime, targetRate:RationalTime) -> RationalTime
        {
            switch self
            {
            case .passthrough:
                return rationalTime
                
            case .assetNominalFrameRate:
                return rationalTime.rescaled(to: targetRate)
                
            case .nearestSMTPERate:
                guard let convertRate = targetRate.rate.closestValueIn(Double.validTimecodeRates) else { return rationalTime }
                return rationalTime.rescaled(to: convertRate)
            }
        }
        
        func convert(_ rationalTime:RationalTime, targetRate:Double) -> RationalTime
        {
            switch self
            {
            case .passthrough:
                return rationalTime
                
            case .assetNominalFrameRate:
                return rationalTime.rescaled(to: targetRate)
                
            case .nearestSMTPERate:
                guard let convertRate = targetRate.closestValueIn(Double.validTimecodeRates) else { return rationalTime }
                return rationalTime.rescaled(to: convertRate)
            }
        }
        
        func convert(_ timeRange:TimeRange, targetRate:Double) -> TimeRange
        {
            let start =  self.convert(timeRange.startTime, targetRate: targetRate)
            let duration = self.convert(timeRange.duration, targetRate: targetRate)
            
            return TimeRange(startTime: start, duration: duration)
        }
        
        func convert(_ timeRange:TimeRange, targetRate:RationalTime) -> TimeRange
        {
            let start =  self.convert(timeRange.startTime, targetRate: targetRate)
            let duration = self.convert(timeRange.duration, targetRate: targetRate)
            
            return TimeRange(startTime: start, duration: duration)
        }
    }

    // How do we handle any Timecode Offsets
    public enum TimecodeOffsetPolicy
    {
        // Use track time, typically zero to track duration
        case trackTime
        
        // Offset track time by any available Time Code on the asset
        case timecode
    }
    
    public let globalStartTime:RationalTime
    public let urlPolicy:URLPolicy
    public let rationalTimeConversionPolicy:RationalTimeConversionPolicy
    public let timecodePolicy:TimecodeOffsetPolicy
    
    public init(globalStartTime: RationalTime, urlPolicy: URLPolicy, rationalTimeConversionPolicy: RationalTimeConversionPolicy, timecodePolicy: TimecodeOffsetPolicy)
    {
        self.globalStartTime = globalStartTime
        self.urlPolicy = urlPolicy
        self.rationalTimeConversionPolicy = rationalTimeConversionPolicy
        self.timecodePolicy = timecodePolicy
    }
}
