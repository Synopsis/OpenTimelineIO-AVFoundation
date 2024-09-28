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
        
        if targetURL.hasPrefix("file://")
        {
            let fileURL = URL(fileURLWithPath:targetURL.replacingOccurrences(of:"file://", with: "./"))
            if
               let asset = self.testForAsset(url:fileURL, baseURL:baseURL)
            {
                return asset
            }
         
            return nil
        }
        else
        {
            if let asset = self.testForAsset(path:targetURL, baseURL: baseURL)
            {
                return asset
            }
        }

        return nil
    }
    
    fileprivate func testForAsset(url:URL, baseURL:URL?) -> AVURLAsset?
    {
        return self.testForAsset(path: url.standardizedFileURL.absoluteURL.path(), baseURL: baseURL)
    }
    
    fileprivate func testForAsset(path:String, baseURL:URL?) -> AVURLAsset?
    {
        if FileManager.default.fileExists(atPath: path)
        {
            let sourceURL = URL(filePath: path)
            return AVURLAsset(url: sourceURL)
        }
        else if let baseURL = baseURL
        {
            // try niave base relative
            var sourceURL = baseURL.appending(path: path )
            
            if FileManager.default.fileExists(atPath: sourceURL.path(percentEncoded: false))
            {
                return AVURLAsset(url: sourceURL)
            }
            
            // we cant have a base url with a relative path to root dir...
            if path.hasPrefix("/")
            {
                var pathWithoutRoot = path
                pathWithoutRoot.removeFirst()
                var sourceURL = baseURL.appending(path: pathWithoutRoot )
                if FileManager.default.fileExists(atPath: sourceURL.path(percentEncoded: false))
                {
                    return AVURLAsset(url: sourceURL)
                }
            }
        }
        
        return nil
    }
}

