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
            var timeRangeInAsset = self.sourceRange?.toCMTimeRange()
        else
        {
            return nil
        }

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
