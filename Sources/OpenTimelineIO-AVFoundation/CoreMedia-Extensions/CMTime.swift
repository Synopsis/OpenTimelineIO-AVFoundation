//
//  File.swift
//  
//
//  Created by Anton Marini on 2/9/24.
//

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
