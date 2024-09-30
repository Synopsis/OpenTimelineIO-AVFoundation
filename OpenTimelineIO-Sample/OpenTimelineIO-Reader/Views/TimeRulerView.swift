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
struct TimeRulerView: View
{

    var timeline: OpenTimelineIO.Timeline
    @Binding var secondsToPixels: Double
    @Binding var currentTime: OpenTimelineIO.RationalTime

    var body: some View
    {
        Canvas { context, size in
            
            let safeRange = getSafeRange()
            let startSeconds = safeRange.startTime.toSeconds()
            let endSeconds = startSeconds + safeRange.duration.toSeconds()
            
            // Draw ticks (including frame-level ticks)
            drawTicks(context: context, startSeconds: startSeconds, endSeconds: endSeconds, secondsToPixels: secondsToPixels, size: size)
            
            // Draw playhead
            drawPlayhead(context: context, currentTime: currentTime, secondsToPixels: secondsToPixels, size: size)
        }
        .frame(width: self.getSafeWidth())
    }
    
    func drawTicks(context: GraphicsContext, startSeconds: Double, endSeconds: Double, secondsToPixels: Double, size: CGSize)
    {
        let maxPixelX = size.width
        
        let frameRate = getFrameRate() // Get the frame rate of the timeline
        let frameDuration = 1.0 / frameRate // Duration of one frame in seconds

        for timeInSeconds in stride(from: startSeconds, through: endSeconds, by: frameDuration)
        {
            let positionX = (timeInSeconds - startSeconds) * secondsToPixels
            
            // Skip if out of canvas bounds
            guard positionX >= 0, positionX <= maxPixelX else { continue }
            
            let tickHeight: CGFloat
            let label: String?
            
            // Determine if it's an hour, minute, second, or frame tick
            let frames = timeInSeconds.truncatingRemainder(dividingBy: frameDuration)
            let seconds = timeInSeconds.truncatingRemainder(dividingBy: 60) 
            let minutes = (timeInSeconds / 60).truncatingRemainder(dividingBy: 60)
            let hours = (timeInSeconds / 3600).truncatingRemainder(dividingBy: 24)
            
            if seconds == 0
            {
                // Hour tick
                tickHeight = 10
                label = String(seconds)

            }
            else if minutes == 0
            {
                // Hour tick
                tickHeight = 20
                label = String(format: "%02d:%02d:00", Int(hours), Int(minutes))
            }
            else if hours == 0
            {
                // Minute tick
                tickHeight = 15
                label = String(format: "%02d:%02d:00", Int(hours), Int(minutes))
            }
            else
            {
                // Frame tick (smaller tick)
                tickHeight = 5
                label = nil
            }
        
//            else if frames == 0
//            {
//                // Second tick
//                tickHeight = 10
//                label = String(frames)
//            }
//            else
//            {
//            }
//            
            // Draw tick line
            let tickRect = CGRect(x: positionX, y: size.height - tickHeight, width: 1, height: tickHeight)
            context.fill(Path(tickRect), with: .color(.white))
            
            // Draw label if it's an hour or minute
            if let label = label
            {
                context.draw(Text(label).font(.system(size: 10)).foregroundStyle(.white), at: CGPoint(x: positionX + 2, y: size.height - tickHeight - 10))
            }
        }
    }
    
    func drawPlayhead(context: GraphicsContext, currentTime: OpenTimelineIO.RationalTime, secondsToPixels: Double, size: CGSize)
    {
        print("drawing playhead at \(currentTime)")
        let playheadPositionX = currentTime.toSeconds() * secondsToPixels
        let playheadRect = CGRect(x: playheadPositionX, y: 0, width: 2, height: size.height)
        context.fill(Path(playheadRect), with: .color(.red))
    }

    // New function to get frame rate of the timeline
    func getFrameRate() -> Double {
        do {
            let rate = try timeline.globalStartTime?.rate ?? 24.0 // Default to 24 fps if unavailable
            return rate
        } catch {
            return 24.0 // Fallback to default frame rate
        }
    }
    
    func getSafeRange() -> OpenTimelineIO.TimeRange {
        var range: OpenTimelineIO.TimeRange
        do {
            range = try TimeRange(startTime: timeline.globalStartTime ?? RationalTime(), duration: timeline.duration())
        } catch {
            range = TimeRange()
        }
        return range
    }
    
    func getSafeWidth() -> CGFloat {
        return self.getSafeRange().duration.toSeconds() * self.secondsToPixels
    }
}
