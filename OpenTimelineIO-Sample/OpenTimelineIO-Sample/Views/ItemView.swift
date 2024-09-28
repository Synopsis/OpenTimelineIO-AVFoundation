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
        
    @Binding var secondsToPixels:Double
    
    var body: some View
    {
            ZStack {
                
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(.white, lineWidth: 1)
                    .fill(.white.opacity(0.2))
                    .frame(width: self.getSafeWidth() - 2)

                Text(item.name)
                    .lineLimit(1)
                    .font(.system(size: 10))
                    .frame(width: self.getSafeWidth())

            }
            .frame(width: self.getSafeWidth())
//            .position(x:self.getSafePositionX() , y:geometry.size.height * 0.5 )
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
        return max(self.getSafeRange().duration.toSeconds() * self.secondsToPixels, 3.0)
    }
    
    func getSafePositionX() -> CGFloat
    {
        return  self.getSafeRange().startTime.toSeconds() * self.secondsToPixels - self.getSafeWidth()/2.0
    }
}
