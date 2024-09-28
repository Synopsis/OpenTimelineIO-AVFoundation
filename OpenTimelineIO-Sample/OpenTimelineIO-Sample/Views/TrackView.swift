//
//  TrackView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/27/24.
//


import OpenTimelineIO_AVFoundation
import OpenTimelineIO
import TimecodeKit
import SwiftUI

struct TrackView : View
{
    var track:OpenTimelineIO.Track
    var backgroundColor:Color
    @Binding var secondsToPixels:Double

    var body: some View
    {
        let items:[Item] = track.children.compactMap( { guard let item = $0 as? Item else { return nil }; return item })
        
        LazyHStack(alignment: .top, spacing: 0, pinnedViews: [.sectionHeaders])
        {
            Section(header:
                        
            ZStack {
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color("TrackHeaderColor"))
//                    .strokeBorder(.white, lineWidth: 1)
                
                Text(track.name)
                    .lineLimit(1)
                    .font(.system(size: 10))
            }
                .frame(width: 100)

            )
            {
             
                
                ForEach(items, id: \.self) { item in
               
                        ItemView(item: item,
                                 backgroundColor: self.backgroundColor,
                                 secondsToPixels: self.$secondsToPixels)
                    
                    
                   
                    
                }
            }
        }
        .frame(width: self.getSafeWidth(), alignment: .leading )
//        .position(x:self.getSafePositionX(), y:0 )
    }
    
    func getSafeRange() -> OpenTimelineIO.TimeRange
    {
        var range:OpenTimelineIO.TimeRange
        do
        {
            range = try track.trimmedRangeInParent() ?? track.rangeInParent()
            
        }
        catch
        {
            range = TimeRange()
        }
        
        return range
    }
    
    func getSafeWidth() -> CGFloat
    {
        return self.getSafeRange().duration.toSeconds() * self.secondsToPixels + 100
    }
    
    func getSafePositionX() -> CGFloat
    {
        return self.getSafeRange().startTime.toSeconds() * self.secondsToPixels - self.getSafeWidth()/2.0
    }
}
