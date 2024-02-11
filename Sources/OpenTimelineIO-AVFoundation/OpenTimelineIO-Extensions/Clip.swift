//
//  Clip.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


import Foundation
import CoreMedia
import AVFoundation
import OpenTimelineIO

extension Clip
{
    func toAVAssetAndMapping() throws -> (asset:AVAsset, timeMaping:CMTimeMapping)?
    {
        guard
            let externalReference = self.mediaReference as? ExternalReference,
            let asset = externalReference.toAVAsset(),
            let timeRangeInAsset = self.sourceRange?.toCMTimeRange()
        else
        {
            return nil
        }

        let rangeInParent = try self.rangeInParent().toCMTimeRange()

        return (asset, CMTimeMapping(source: timeRangeInAsset, target:rangeInParent))
    }
}
