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
    
    let item:OpenTimelineIO.Item
    let backgroundColor:Color
    let selected:Bool
    
    private var isGap: Bool {
        item.isKind(of: Gap.self)
    }

    @Binding var secondsToPixels:Double
    
    var body: some View
    {
        ZStack
        {
            let fill:AnyShapeStyle = ( isGap ) ? AnyShapeStyle( Color("GapTrackBaseColor") ) : AnyShapeStyle(self.backgroundColor.gradient)
            let textGapOpacity:Double = ( isGap ) ? 0.0 : 1.0
            
            RoundedRectangle(cornerRadius: 3)
                .fill(fill, style: FillStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(self.selected ? .orange : .clear, lineWidth: 1) // Add stroke/outline
                        .frame(width: self.getSafeWidth() - 2)
                )
                .frame(width: self.getSafeWidth() - 2)
            
            Text(item.name)
                .lineLimit(1)
                .font(.system(size: 10))
                .frame(width: self.getSafeWidth())
                .opacity(self.getSafeWidth() > 40 ? textGapOpacity : 0.0)
        }
        .frame(width: self.getSafeWidth(), alignment: .leading )
        .overlay {
            // TODO: Get item marker coordinate system working
//            self.getMarkerView()
        }
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
    
    @ViewBuilder func getMarkerView() -> some View
    {
        HStack(alignment: .top)
        {
            let markerRange = self.item.markers.startIndex ..< self.item.markers.endIndex
            ForEach(markerRange, id:\.self) { markerIndex in
                MarkerView(marker: self.item.markers[markerIndex],
                           secondsToPixels: self.$secondsToPixels)
            }
        }
        .frame(width: self.getSafeWidth(), alignment: .leading )

    }
}
