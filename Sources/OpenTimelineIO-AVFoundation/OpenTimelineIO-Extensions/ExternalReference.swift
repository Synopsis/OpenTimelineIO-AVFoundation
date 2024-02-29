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
    func toAVAsset(baseURL:URL? = nil) -> AVURLAsset?
    {
        guard
            let targetURL = self.targetURL
        else
        {
            return nil
        }
        
        if targetURL.hasPrefix("file:")
        {
            if let sourceURL = URL(string: targetURL)
            {
                return AVURLAsset(url: sourceURL)
            }
        }
        else
        {
            if let sourceURL = baseURL?.appending(path: targetURL)
            {
                return AVURLAsset(url: sourceURL)
            }
        }

        return nil
    }
}

