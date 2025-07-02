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
    static let trackHeight:CGFloat = 35
    
    let track:OpenTimelineIO.Track
    let backgroundColor:Color
    @Binding var secondsToPixels:Double
    @Binding var selectedItem:Item?

    var body: some View
    {
        let items:[Item] = track.children.compactMap( { guard let item = $0 as? Item else { return nil }; return item })
        
        LazyHStack(alignment: .top, spacing: 0, pinnedViews: [.sectionHeaders])
        {
            Section(header: self.headerView() )
           {
                ForEach(0..<items.count, id: \.self) { index in
                    let item = items[index]

                    ItemView(item: item,
                             backgroundColor: self.backgroundColor,
//                             backgroundColor: [Color.red, Color.blue, Color.green, Color.yellow, Color.purple].randomElement()!,
                             selected: item == self.selectedItem,
                             secondsToPixels: self.$secondsToPixels)
                    
                    .onTapGesture {
                        self.selectedItem = item
                        print("selected Item")
                    }
                }
            }
        }
        .frame(width: self.getSafeWidth(), height:Self.trackHeight, alignment: .leading )
        .overlay {
            self.getMarkerView()
        }
//        .position(x:self.getSafePositionX(), y:0 )
    }
    
    func headerView() -> some View
    {
        ZStack {
            
            RoundedRectangle(cornerRadius: 3)
                .fill(Color("TrackHeaderColor").gradient)
            //                    .strokeBorder(.white, lineWidth: 1)
            
            Text(track.name)
                .lineLimit(1)
                .font(.system(size: 10))
                .bold()
        }
        .frame(width: 100, height:Self.trackHeight)
        .onTapGesture {
            self.selectedItem = track
            print("selected Item")
        }
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
    
    @ViewBuilder func getMarkerView() -> some View
    {
        HStack(alignment: .top)
        {
            let markerRange = self.track.markers.startIndex ..< self.track.markers.endIndex
            ForEach(markerRange, id:\.self) { markerIndex in
                MarkerView(marker: self.track.markers[markerIndex],
                           secondsToPixels: self.$secondsToPixels)
            }
        }
    }
}
