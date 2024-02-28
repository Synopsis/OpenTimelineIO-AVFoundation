//
//  CMTimeRange.swift
//  
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import Foundation
import CoreMedia
import OpenTimelineIO

public extension CMTimeRange
{
    func toOTIOTimeRange() -> TimeRange
    {
        return TimeRange(startTime: self.start.toOTIORationalTime(), duration: self.duration.toOTIORationalTime() )
    }
    
    func computeMissingTimeRanges(subRange: CMTimeRange) -> [CMTimeRange] 
    {
        let fullRange = self
        // Calculate the intersection between the full range and the sub range
        let intersection = fullRange.intersection(subRange)

        // If there is no intersection, the entire full range is missing
        if intersection.duration == CMTime.zero
        {
            return [fullRange]
        }

        // If the intersection starts after the full range, add the time before the intersection
        var missingRanges: [CMTimeRange] = []
        if intersection.start > fullRange.start 
        {
            let beforeIntersection = CMTimeRange(start: fullRange.start, end: intersection.start)
            missingRanges.append(beforeIntersection)
        }

        // If the intersection ends before the full range, add the time after the intersection
        if intersection.end < fullRange.end 
        {
            let afterIntersection = CMTimeRange(start: intersection.end, end: fullRange.end)
            missingRanges.append(afterIntersection)
        }

        return missingRanges
    }
}
