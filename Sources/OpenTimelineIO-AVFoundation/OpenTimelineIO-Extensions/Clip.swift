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
    func toAVAssetAndMapping(baseURL:URL? = nil) throws -> (asset:AVAsset, timeMaping:CMTimeMapping)?
    {
        guard
            let externalReference = self.mediaReference as? ExternalReference,
            let asset = externalReference.toAVAsset(baseURL: baseURL),
            var timeRangeInAsset = self.sourceRange?.toCMTimeRange(),
            let parent = self.parent as? Item
        else
        {
            return nil
        }
        
        // This accounts for visible ranges which also account for transition times
//        var timeRangeInAsset = try self.visibleRange().toCMTimeRange()
//        let rangeInParent = try self.transformed(timeRange: self.visibleRange(), toItem:parent ).toCMTimeRange()
        
        // if we dont w`ant this, we would rather do:
         let rangeInParent = try self.rangeInParent().toCMTimeRange()

        // if we have timecode from our asset
        do
        {
            if let timecodeCMTime = try asset.startTimecode()?.cmTimeValue
            {
                timeRangeInAsset = CMTimeRange(start: timeRangeInAsset.start - timecodeCMTime, duration: timeRangeInAsset.duration )
            }
        }
        catch Timecode.MediaParseError.missingOrNonStandardFrameRate
        {
            // not an error
        }
        
        return (asset, CMTimeMapping(source: timeRangeInAsset, target:rangeInParent))
    }
}
