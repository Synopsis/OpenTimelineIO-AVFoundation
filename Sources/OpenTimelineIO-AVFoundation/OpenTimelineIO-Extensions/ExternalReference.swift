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

extension ExternalReference
{
    func toAVAsset() -> AVAsset?
    {
        guard
            let targetURL = self.targetURL,
            let sourceURL = URL(string: targetURL)
        else
        {
            return nil
        }
        
        return AVURLAsset(url: sourceURL)
    }
}

