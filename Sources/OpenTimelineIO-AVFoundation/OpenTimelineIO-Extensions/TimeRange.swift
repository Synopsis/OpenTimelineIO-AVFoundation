//
//  File.swift
//  
//
//  Created by Anton Marini on 2/9/24.
//

import Foundation
import CoreMedia
import OpenTimelineIO

public extension TimeRange
{
    func toCMTimeRange() -> CMTimeRange
    {
        return CMTimeRange(start: self.startTime.toCMTime(), duration: self.duration.toCMTime() )
    }
}
