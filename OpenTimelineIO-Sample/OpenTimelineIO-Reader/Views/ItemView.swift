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
    
    @State var item:OpenTimelineIO.Item
    @State var backgroundColor:Color
    @State var selected:Bool

    @Binding var secondsToPixels:Double
    
    var body: some View
    {

            ZStack {
                
                if let _ = item as? Gap
                {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder( self.selected ? .white : .clear, lineWidth: 1)
                        .foregroundStyle( Color("GapTrackBaseColor") )
                        .frame(width: self.getSafeWidth() - 2)
                }
                else
                {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder( self.selected ? .white : .clear, lineWidth: 1)
                        .foregroundStyle( self.backgroundColor.gradient )
                        .frame(width: self.getSafeWidth() - 2)
                    
                    Text(item.name)
                        .lineLimit(1)
                        .font(.system(size: 10))
                        .frame(width: self.getSafeWidth())
                }
            }
            .frame(width: self.getSafeWidth())
//            .offset(x:self.getSafePositionX() )//, y:geometry.size.height * 0.5 )
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
        return  self.getSafeRange().startTime.toSeconds() * self.secondsToPixels// + self.getSafeWidth()/2.0
    }
}
