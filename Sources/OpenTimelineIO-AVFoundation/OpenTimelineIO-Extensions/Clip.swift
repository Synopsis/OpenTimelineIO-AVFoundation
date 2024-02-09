//
//  File.swift
//  
//
//  Created by Anton Marini on 2/9/24.
//

import Foundation
import CoreMedia
import AVFoundation
import OpenTimelineIO

extension Clip
{
    func toAVAssetAndMapping() -> (asset:AVAsset, timeMaping:CMTimeMapping)?
    {
        guard
            let externalReference = self.mediaReference as? ExternalReference,
            let asset = externalReference.toAVAsset(),
            let timeRangeInAsset = self.sourceRange?.toCMTimeRange()
            let trimmedRangeInParent = self.trimmedRangeInParent()?.toCMTimeRange()
        else
        {
            return nil
        }
        
        return (asset, CMTimeMapping(source: trimmedRangeInParent, target: timeRangeInAsset))
    }
}
