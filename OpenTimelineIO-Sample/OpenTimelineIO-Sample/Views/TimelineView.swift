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
        
    var body: some View
    {
        let videoTracks = timeline.videoTracks
        let audioTracks = timeline.audioTracks

        GeometryReader { geom in
            ScrollView([.horizontal, .vertical])
            {
                VStack(alignment:.leading, spacing: 0)
                {
                    ForEach(videoTracks, id:\.self) { track in
                        
                        TrackView(track: track)
                            .background(.orange)
                            .frame(minWidth: geom.size.width)
                            .frame(height:10)
                    }
                    
                    ForEach(audioTracks, id:\.self) { track in
                        
                        TrackView(track: track)
                            .background(.blue)
                            .frame(minWidth: geom.size.width)
                            
                    }
                }
            }
            .frame(width: geom.size.width)
            .frame(minHeight:50, maxHeight: 300)
        }

        
    }
               

   
}
