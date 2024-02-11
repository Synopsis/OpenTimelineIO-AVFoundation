//
//  CMTime.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import Foundation
import CoreMedia
import OpenTimelineIO

public extension CMTime
{
    func toOTIORationalTime() -> RationalTime
    {
        return RationalTime(value: Double( self.value ), rate: Double( self.timescale ) )
    }
}
