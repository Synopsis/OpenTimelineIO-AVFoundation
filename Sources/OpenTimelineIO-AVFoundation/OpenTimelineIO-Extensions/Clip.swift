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
    func toAVAssetAndMapping(baseURL:URL? = nil, useTimecode:Bool = false, rescaleToAsset:Bool = true) throws -> (asset:AVAsset, timeMaping:CMTimeMapping)?
    {
        guard
            let externalReference = self.mediaReference as? ExternalReference,
            let asset = externalReference.toAVAsset(baseURL: baseURL)
//            let parent = self.parent as? Item
        else
        {
            return nil
        }
        
        var timeRangeInAsset = try self.availableRange()
        var rangeInParent = try self.trimmedRange()

        var minFrameDuration:RationalTime? = nil
        if let videoTrack = asset.tracks(withMediaType: .video).first,
            rescaleToAsset
        {
            minFrameDuration = videoTrack.minFrameDuration.toOTIORationalTime()
        }
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = rangeInParent.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = rangeInParent.duration.rescaled(to: minFrameDuration)
            
            rangeInParent = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        // if we have timecode from our asset
        if useTimecode
        {
            do
            {
                if let timecodeCMTime = try asset.startTimecode()?.cmTimeValue.toOTIORationalTime()
                {
                    timeRangeInAsset = TimeRange(startTime: timeRangeInAsset.startTime - timecodeCMTime, duration: timeRangeInAsset.duration)
                }
            }
            catch Timecode.MediaParseError.missingOrNonStandardFrameRate
            {
                // not an error
            }
        }
        
        // Add rescaling - see Additional Notes above
        if let minFrameDuration = minFrameDuration
        {
            let rescaledStart = timeRangeInAsset.startTime.rescaled(to: minFrameDuration)
            let rescaledDuration = timeRangeInAsset.duration.rescaled(to: minFrameDuration)
            
            timeRangeInAsset = TimeRange(startTime: rescaledStart, duration: rescaledDuration)
        }
        
        return (asset, CMTimeMapping(source: timeRangeInAsset.toCMTimeRange(), target:rangeInParent.toCMTimeRange()))
    }
}
