//
//  CMTime.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import Foundation
import CoreMedia
import OpenTimelineIO
import TimecodeKit

public extension CMTime
{
    func toOTIORationalTime() -> RationalTime
    {
        let fraction = Fraction(reducing: Int(self.value), Int(self.timescale))
                
        return RationalTime(value: Double( fraction.numerator ), rate: Double( fraction.denominator ) )
    }
}
