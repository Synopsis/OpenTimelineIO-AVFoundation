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
    
    @Binding var secondsToPixels:Double
    
    var body: some View
    {
        let videoTracks = timeline.videoTracks
        let audioTracks = timeline.audioTracks
        
        let videoTrackColors = [
            Color("VideoTrackBaseColor").gradient,//.saturation(1.0).opacity(0.75),
            Color("VideoTrackBaseColor").gradient,//.saturation(0.9).opacity(0.75),
            Color("VideoTrackBaseColor").gradient,//.saturation(0.8).opacity(0.75),
            Color("VideoTrackBaseColor").gradient,//.saturation(0.7).opacity(0.75),
            Color("VideoTrackBaseColor").gradient,//.saturation(0.6).opacity(0.75),
        ]
        
        let audioTrackColors = [
            Color("AudioTrackBaseColor").gradient,//.saturation(1.0).opacity(0.75),
            Color("AudioTrackBaseColor").gradient,//.saturation(0.9).opacity(0.75),
            Color("AudioTrackBaseColor").gradient,//.saturation(0.8).opacity(0.75),
            Color("AudioTrackBaseColor").gradient,//.saturation(0.7).opacity(0.75),
            Color("AudioTrackBaseColor").gradient,//.saturation(0.6).opacity(0.75),
        ]
        
        ScrollView([.horizontal, .vertical])
        {
            
            VStack(alignment:.leading, spacing: 3)
            {
//                TimeRulerView(timeline: self.timeline, secondsToPixels: self.$secondsToPixels)
//                    .background(.red)
//                
//                Divider()
                
                ForEach(0..<videoTracks.count) { index in
                    
                    let track = videoTracks[index]
                    let color = videoTrackColors[index % videoTrackColors.count]
                    
                    TrackView(track: track, backgroundColor: Color("VideoTrackBaseColor"), secondsToPixels: self.$secondsToPixels )
                    
                }
                
                Divider()
                
                ForEach(0..<audioTracks.count) { index in

                    let track = audioTracks[index]
                    let color = audioTrackColors[index % audioTrackColors.count]
                    
                    TrackView(track: track, backgroundColor: Color("AudioTrackBaseColor"), secondsToPixels: self.$secondsToPixels )

                }
            }
            .frame(height: CGFloat((videoTracks.count + audioTracks.count)) * 25 )
            .frame(maxHeight: CGFloat((videoTracks.count + audioTracks.count)) * 500)
        }
        
      
        
    }
    
    
    
}
