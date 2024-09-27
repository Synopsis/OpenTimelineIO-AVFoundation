//
//  ItemView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/27/24.
//

import OpenTimelineIO_AVFoundation
import OpenTimelineIO
import TimecodeKit
import SwiftUI

struct ItemView : View {
    
    var item:OpenTimelineIO.Item
        
    var body: some View
    {
        RoundedRectangle(cornerRadius: 3)
            .strokeBorder(.white, lineWidth: 1)
            .frame(width: self.getSafeWidth() )
            .position(x:self.getSafePositionX(), y:0 )
    }

    func getSafeRange() -> OpenTimelineIO.TimeRange
    {
        var range:OpenTimelineIO.TimeRange
        do
        {
            range = try item.trimmedRangeInParent() ?? item.rangeInParent()
            
        }
        catch
        {
            range = TimeRange()
        }
        
        return range
    }
    
    func getSafeWidth() -> CGFloat
    {
        return self.getSafeRange().duration.toSeconds() * 10
    }
    
    func getSafePositionX() -> CGFloat
    {
        return self.getSafeRange().startTime.toSeconds() * 10 + self.getSafeWidth()/2.0
    }
}
