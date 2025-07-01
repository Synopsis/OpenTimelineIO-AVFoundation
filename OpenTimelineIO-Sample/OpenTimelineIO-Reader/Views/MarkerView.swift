//
//  MarkerView.swift
//  OpenTimelineIO-Reader
//
//  Created by Anton Marini on 7/1/25.
//

import OpenTimelineIO_AVFoundation
import OpenTimelineIO
import TimecodeKit
import SwiftUI

struct MarkerView : View {
    
    let marker:OpenTimelineIO.Marker
    
    @Binding var secondsToPixels:Double
    
    var body: some View
    {
        self.colorForMarker()
            .frame(width: self.getSafeWidth() )
            .offset(x:self.getSafePositionX() )
    }
    
    func getSafeWidth() -> CGFloat
    {
        return max(self.marker.markedRange.duration.toSeconds() * self.secondsToPixels, 3.0)
    }
    
    func getSafePositionX() -> CGFloat
    {
        return  self.marker.markedRange.startTime.toSeconds() * self.secondsToPixels// + self.getSafeWidth()/2.0
    }
    
    func colorForMarker() -> Color
    {
        if let color:Marker.Color = Marker.Color(rawValue: marker.color)
        {
            switch color
            {
            case .pink : return Color.pink
            case .red : return Color.red
            case .orange : return Color.orange
            case .yellow : return Color.yellow
            case .green : return Color.green
            case .cyan : return Color.cyan
            case .blue : return Color.blue
            case .purple : return Color.purple
            case .magenta : return Color(red: 1.0, green: 0, blue: 1.0)
            case .black : return Color.black
            case .white : return Color.white

            }
        }
        
        return Color.red
    }
}
