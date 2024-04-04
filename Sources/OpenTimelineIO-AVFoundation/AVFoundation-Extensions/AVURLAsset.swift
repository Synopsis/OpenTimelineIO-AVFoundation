//
//  File.swift
//  
//
//  Created by Anton Marini on 4/4/24.
//

import Foundation
import AVFoundation
import CoreMedia
import OpenTimelineIO
import TimecodeKit

public extension AVURLAsset
{
    
    /// Returns the nominal frame rate as `Float` for each video track.
    func readNominalVideoFrameRates() -> [Float] {
        tracks(withMediaType: .video)
            .map(\.nominalFrameRate)
    }
    
    func readMinFrameDurations() -> [CMTIme] {
        tracks(withMediaType: .video)
            .map(\.minFrameDuration)
    }

    
    func toOTIOExternalReference(config:OTIOConversionConfig) -> ExternalReference
    {
        
        // MARK: - TimeCode Policy
        var timeRange = CMTimeRange(start: .zero, duration:  self.duration)
        
        switch config.timecodePolicy
        {
        case .timecode:
                do
                {
                    if let timecode = try self.startTimecode()
                    {
                        timeRange = CMTimeRange(start:timeRange.start + timecode.cmTimeValue, duration: timeRange.duration)
                    }
                }
                catch
                {
                    // no - op
                }
            break
        case .trackTime:
            break
        }
    
        var timeRangeRational = timeRange.toOTIOTimeRange()
        
        // MARK: - Time Conversion Policy
        if let firstMinFrameDuration = self.readMinFrameDurations().first
        {
            timeRangeRational = config.rationalTimeConversionPolicy.convert(timeRangeRational, targetRate: firstMinFrameDuration.toOTIORationalTime() )
        }
       
        
        // MARK: - URL Policy 
        var targetURL:String = ""
        
        switch config.urlPolicy
        {
        case .absolutePath:
            targetURL = self.url.standardizedFileURL.path()
            break
        case .fileURL:
            targetURL = self.url.standardizedFileURL.absoluteString
            break
        case .relativePath(let root):
            targetURL = URL(string: self.url.standardizedFileURL.path(), relativeTo: URL(string: root))!.path()
        }
        
        return ExternalReference(targetURL: targetURL, availableRange: timeRangeRational )
    }
}
