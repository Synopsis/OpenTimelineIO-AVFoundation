//
//  ExternalReference.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project


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

