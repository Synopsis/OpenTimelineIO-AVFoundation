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
            if 
                let sourceURL = URL(string: targetURL),
                let asset = self.testForAsset(path:sourceURL.standardizedFileURL.path)
            {
                return asset
            }
            
            return nil
        }
        else
        {
            if let asset = self.testForAsset(path:targetURL)
            {
                return asset
            }
            
            if let baseURL
            {
                if let asset = self.testForAsset(url: baseURL.appending(path: targetURL ) )
                {
                    return asset
                }
            }
        }

        return nil
    }
    
    fileprivate func testForAsset(url:URL) -> AVURLAsset?
    {
        return self.testForAsset(path: url.standardizedFileURL.path)
    }
    
    fileprivate func testForAsset(path:String) -> AVURLAsset?
    {
        if FileManager.default.fileExists(atPath: path)
        {
            let sourceURL = URL(filePath: path)
            return AVURLAsset(url: sourceURL)
        }
        
        return nil
    }
}

