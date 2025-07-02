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
    
    let timeline:OpenTimelineIO.Timeline
    
    @Binding var currentTime:RationalTime
    @Binding var secondsToPixels:Double
    @Binding var selectedItem:Item?
    
    @State private var hitTestEnabled:Bool = true
    
    var body: some View
    {
        // Lame scroll view optimizations.
        // It seems as though hit testing for selection causes massive slowdowns in SwiftUI
        // Due to how recursive hit testing happens
        // We disable hit testing using macos 15 onScrollPhaseChange
        
        if #available(macOS 15.0, *) {
            ScrollView([.horizontal, .vertical])
            {
                self.timelineView()
                    .allowsHitTesting(self.hitTestEnabled)
//                    .drawingGroup(opaque: true)

            }
            .onScrollPhaseChange({ oldPhase, newPhase, context in
                guard oldPhase != newPhase else { return }
                
                self.hitTestEnabled = !newPhase.isScrolling
            })
            .frame(idealHeight: ( CGFloat((timeline.videoTracks.count + timeline.audioTracks.count)) * TrackView.trackHeight) + 100 )
    //        .frame(maxHeight: CGFloat((videoTracks.count + audioTracks.count)) * 500)

        }
        else
        {
            // Fallback on earlier versions
            ScrollView([.horizontal, .vertical])
            {
                self.timelineView()
            }
        }
    }
    
    @ViewBuilder func timelineView() -> some View
    {
        let videoTracks = timeline.videoTracks
        let audioTracks = timeline.audioTracks

        VStack(alignment:.leading, spacing: 3)
        {
            TimeRulerView(timeline: self.timeline, secondsToPixels: self.$secondsToPixels, currentTime: self.$currentTime )
                    .frame(height: 50)
                    .offset(x:100)
            
            ForEach(0..<videoTracks.count, id: \.self) { index in
                
                // Reverse
                let track = videoTracks[(videoTracks.count - 1 ) - index]
                
                TrackView(track: track,
                          backgroundColor: Color("VideoTrackBaseColor"),
                          secondsToPixels: self.$secondsToPixels,
                          selectedItem: self.$selectedItem )
            }
            
            Spacer()
            Divider()
            Spacer()

            ForEach(0..<audioTracks.count, id: \.self) { index in
                
                let track = audioTracks[index]
                
                TrackView(track: track,
                          backgroundColor: Color("AudioTrackBaseColor"),
                          secondsToPixels: self.$secondsToPixels,
                          selectedItem: self.$selectedItem )
            }
        }

    }
}
