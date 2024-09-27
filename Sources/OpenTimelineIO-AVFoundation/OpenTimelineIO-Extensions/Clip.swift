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
    func toAVAssetAndMapping(baseURL:URL? = nil, useTimecode:Bool = true, rescaleToAsset:Bool = true) throws -> (asset:AVAsset, timeMaping:CMTimeMapping)?
    {
        guard
            let externalReference = self.mediaReference as? ExternalReference,
            let asset = externalReference.toAVAsset(baseURL: baseURL)
//            let parent = self.parent as? Item
        else
        {
            return nil
        }
        
        var timeRangeInAsset = try self.trimmedRange()
        var timeRangeInParentTrack = try self.trimmedRangeInParent() ?? self.rangeInParent()

        var minFrameDuration:RationalTime? = nil
        if let videoTrack = asset.tracks(withMediaType: .video).first,
            rescaleToAsset
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
        
        // if we have timecode from our asset
//        if useTimecode
//        {
//            do
//            {
//                if let timecodeCMTime = try asset.startTimecode()?.cmTimeValue.toOTIORationalTime()
//                {
//                    timeRangeInAsset = TimeRange(startTime: timeRangeInAsset.startTime - timecodeCMTime, duration: timeRangeInAsset.duration)
//                }
//            }
//            catch Timecode.MediaParseError.missingOrNonStandardFrameRate
//            {
//                // not an error
//            }
//        }
        
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
                    
                    //            let timeRangeInParentTrackNoTC = timeRangeInParentTrack.startTime - startTimeCode.cmTimeValue.toOTIORationalTime()
                    //
                    //            timeRangeInParentTrack = TimeRange(startTime: timeRangeInParentTrackNoTC, duration: timeRangeInParentTrack.duration)
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
