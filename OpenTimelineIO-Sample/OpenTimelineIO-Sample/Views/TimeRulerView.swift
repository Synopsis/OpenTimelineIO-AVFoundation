//
//  TimeRulerView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/28/24.
//

import OpenTimelineIO_AVFoundation
import OpenTimelineIO
import TimecodeKit
import SwiftUI

struct TimeRulerView: View {

    var timeline: OpenTimelineIO.Timeline
    
    @Binding var secondsToPixels:Double;

    var body: some View {
        
            HStack
            {
                Text( getSafeRange().startTime.toSeconds().description )

                Spacer()

                Text( getSafeRange().endTimeExclusive().toSeconds().description )

            }
//            .frame(width: self.getSafeWidth() )
        
       

    }
        
        func getSafeRange() -> OpenTimelineIO.TimeRange
        {
            var range:OpenTimelineIO.TimeRange
            do
            {
                range = try TimeRange(startTime: timeline.globalStartTime ?? RationalTime(), duration: timeline.duration())
                
            }
            catch
            {
                range = TimeRange()
            }
            
            return range
        }
        
        func getSafeWidth() -> CGFloat
        {
            return self.getSafeRange().duration.toSeconds() * self.secondsToPixels
        }
        
        func getSafePositionX() -> CGFloat
        {
            return self.getSafeRange().startTime.toSeconds() * self.secondsToPixels + self.getSafeWidth()/2.0
        }
    
}
