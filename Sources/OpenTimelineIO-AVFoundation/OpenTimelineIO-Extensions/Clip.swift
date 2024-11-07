//
//  Clip.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import Foundation
import CoreMedia
import AVFoundation
import OpenTimelineIO
import TimecodeKit
extension Clip
{
    // see https://opentimelineio.readthedocs.io/en/latest/tutorials/time-ranges.html
    func toAVAssetAndMapping(baseURL:URL? = nil, trackType:AVMediaType,  useTimecode:Bool = true, rescaleToAsset:Bool = true) throws -> (asset:AVAsset, timeMaping:CMTimeMapping)?
    {
        
        let asset:AVURLAsset
        
        if let externalReference = self.mediaReference as? ExternalReference,
            let maybeAsset = externalReference.toAVAsset(baseURL: baseURL)
        {
            
            guard !maybeAsset.tracks(withMediaType: trackType).isEmpty else { return nil }
            
            asset = maybeAsset
        }
        else
        {
            //see AWS Picchu Edit - Premiere cant import either?
            //we have a generator or just a dead reference?
            let missingMediaURL = Bundle.main.url(forResource: "MediaNotFound", withExtension: "mp4")!
            let missingAsset = AVURLAsset(url: missingMediaURL)
            
            guard !missingAsset.tracks(withMediaType: trackType).isEmpty else { return nil }
            
            asset = missingAsset
        }
        
        var timeRangeInAsset = try self.trimmedRange()
        var timeRangeInParentTrack = try self.trimmedRangeInParent() ?? self.rangeInParent()

        var minFrameDuration:RationalTime? = nil
        if let videoTrack = asset.tracks(withMediaType: .video).first,
            rescaleToAsset,
           videoTrack.minFrameDuration.isValid,
           videoTrack.minFrameDuration != .zero
        {
            minFrameDuration = videoTrack.minFrameDuration.toOTIORationalTime()
        }
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = timeRangeInParentTrack.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = timeRangeInParentTrack.duration.rescaled(to: minFrameDuration)
            
            timeRangeInParentTrack = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = timeRangeInAsset.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = timeRangeInAsset.duration.rescaled(to: minFrameDuration)
            
            timeRangeInAsset = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        // add a heuristic - if our asset has timecode we need to subtract the start time
        if useTimecode == true
        {
            do
            {
                if let startTimeCode = try asset.startTimecode()
                {
                    let assetStartTimeNoTC = timeRangeInAsset.startTime - startTimeCode.cmTimeValue.toOTIORationalTime()
                    
                    timeRangeInAsset = TimeRange(startTime: assetStartTimeNoTC, duration: timeRangeInAsset.duration)

                    // We dont need to offset our parent..
//                    let timeRangeInParentTrackNoTC = timeRangeInParentTrack.startTime - startTimeCode.cmTimeValue.toOTIORationalTime()
//                    timeRangeInParentTrack = TimeRange(startTime: timeRangeInParentTrackNoTC, duration: timeRangeInParentTrack.duration)
                }
                
                // We might find ourselves with a situation where the timecode of the source media in the timeline existed, but we are working with proxies without TC
                // This means we need to deduce if the time in OTIO differs from the assets and adjust accordingly
                else if let firstVideoTrackStart = asset.tracks(withMediaType: .video).first
                {
                    let assetAvailableTime = try self.availableRange()

                    // If our start times differ...
                    if firstVideoTrackStart.timeRange.start.toOTIORationalTime() != assetAvailableTime.startTime
                    {
                        let timeDifference = assetAvailableTime.startTime - firstVideoTrackStart.timeRange.start.toOTIORationalTime()
                        
                        let assetStartTimeNoTC = timeRangeInAsset.startTime - timeDifference
                        timeRangeInAsset = TimeRange(startTime: assetStartTimeNoTC, duration: timeRangeInAsset.duration)
                    }
                }
            }
            catch Timecode.MediaParseError.missingOrNonStandardFrameRate
            {
                // not an error
            }
        }
        
        
        return (asset, CMTimeMapping(source:timeRangeInParentTrack.toCMTimeRange(), target:timeRangeInAsset.toCMTimeRange()))
    }
}
