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
    
    func computeGapsOf(subranges: [CMTimeRange]) -> [CMTimeRange] 
    {
        // Start with the full time range
        let fullRange = self
        
        var inverseRanges = [fullRange]

        // Iterate over the source time ranges and subtract them from the current set of inverse ranges
        for subrange in subranges 
        {
            var newInverseRanges: [CMTimeRange] = []

            for inverseRange in inverseRanges 
            {
                // Calculate the intersection between the current inverse range and the source range
                let intersection = inverseRange.intersection(subrange)

                // If there is an intersection, split the current inverse range into two parts
                if intersection.duration > .zero 
                {
                    // Add the part before the intersection
                    let beforeIntersection = CMTimeRange(start: inverseRange.start, end: intersection.start)
                    if beforeIntersection.duration > .zero 
                    {
                        newInverseRanges.append(beforeIntersection)
                    }

                    // Add the part after the intersection
                    let afterIntersection = CMTimeRange(start: intersection.end, end: inverseRange.end)
                    if afterIntersection.duration > .zero 
                    {
                        newInverseRanges.append(afterIntersection)
                    }
                } 
                else
                {
                    // If no intersection, keep the current inverse range as is
                    newInverseRanges.append(inverseRange)
                }
            }

            // Update the set of inverse ranges for the next iteration
            inverseRanges = newInverseRanges
        }

        return inverseRanges
    }
}
