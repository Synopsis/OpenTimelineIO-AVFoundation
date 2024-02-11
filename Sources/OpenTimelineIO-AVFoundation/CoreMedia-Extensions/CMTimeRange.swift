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
}
