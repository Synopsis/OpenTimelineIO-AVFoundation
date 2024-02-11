//
//  TimeRange.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

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
