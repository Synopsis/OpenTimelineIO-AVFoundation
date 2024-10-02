//
//  TimelineView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/27/24.
//

import OpenTimelineIO_AVFoundation
import OpenTimelineIO
import TimecodeKit
import SwiftUI

struct TimelineView : View {
    
    var timeline:OpenTimelineIO.Timeline
    
    @Binding var currentTime:RationalTime
    @Binding var secondsToPixels:Double
    @Binding var selectedItem:Item?
    
    var body: some View
    {
        let videoTracks = timeline.videoTracks
        let audioTracks = timeline.audioTracks
        
        ScrollView([.horizontal, .vertical])
        {
            VStack(alignment:.leading, spacing: 3)
            {
                TimeRulerView(timeline: self.timeline, secondsToPixels: self.$secondsToPixels, currentTime: self.$currentTime )
                    .frame(height: 40)
                    .offset(x:100)
//
//                Divider()
                
                ForEach(0..<videoTracks.count, id: \.self) { index in
                    
                    let track = videoTracks[index]
                    
                    TrackView(track: track,
                              backgroundColor: Color("VideoTrackBaseColor"),
                              secondsToPixels: self.$secondsToPixels,
                              selectedItem: self.$selectedItem )
                }
                
                ForEach(0..<audioTracks.count, id: \.self) { index in

                    let track = audioTracks[index]
                    
                    TrackView(track: track,
                              backgroundColor: Color("AudioTrackBaseColor"),
                              secondsToPixels: self.$secondsToPixels,
                              selectedItem: self.$selectedItem )
                }
            }
            .frame(height: CGFloat((videoTracks.count + audioTracks.count)) * 25 + 50 )
            .frame(maxHeight: CGFloat((videoTracks.count + audioTracks.count)) * 500)
        }
    }
}
