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

struct TrackView : View {
    
    var track:OpenTimelineIO.Track
        
    var body: some View
    {
        let items:[Item] = track.children.compactMap( { guard let item = $0 as? Clip else { return nil }; return item })
        
//        HStack(alignment: .top, spacing: 0)
//        {
            ForEach(items, id: \.self) { item in
                
                ItemView(item: item)
                    
//            }
        }
        .frame(width: self.getSafeWidth() )
        .position(x:self.getSafePositionX(), y:0 )
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
        return self.getSafeRange().duration.toSeconds() * 10
    }
    
    func getSafePositionX() -> CGFloat
    {
        return self.getSafeRange().startTime.toSeconds() * 10 + self.getSafeWidth()/2.0
    }
}
