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
            if let fileURL =  URL(string: targetURL),
                let asset = self.testForAsset(url:fileURL, baseURL: baseURL)
            {
                return asset
            }

            let fileURL = URL(fileURLWithPath:targetURL.replacingOccurrences(of:"file://", with: "./"))
            if let asset = self.testForAsset(url:fileURL, baseURL:baseURL)
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
        return self.testForAsset(path: url.standardizedFileURL.absoluteURL.path(percentEncoded: false), baseURL: baseURL)
    }
    
    fileprivate func testForAsset(path:String, baseURL:URL?) -> AVURLAsset?
    {
        if FileManager.default.fileExists(atPath: path)
        {
            let sourceURL = URL(filePath: path)
            return self.tryLoadAssetAtResolvedURL(url: sourceURL)
        }
        else if let baseURL = baseURL
        {
            // try niave base relative
            var sourceURL = baseURL.appending(path: path )
            
            if FileManager.default.fileExists(atPath: sourceURL.path(percentEncoded: false))
            {
                return self.tryLoadAssetAtResolvedURL(url: sourceURL)
            }
            
            // we cant have a base url with a relative path to root dir...
            if path.hasPrefix("/")
            {
                var pathWithoutRoot = path
                pathWithoutRoot.removeFirst()
                var sourceURL = baseURL.appending(path: pathWithoutRoot )
                if FileManager.default.fileExists(atPath: sourceURL.path(percentEncoded: false))
                {
                    return self.tryLoadAssetAtResolvedURL(url: sourceURL)
                }
            }
        }
        
        let missingMediaURL = Bundle.main.url(forResource: "MediaNotFound", withExtension: "mp4")!
        
        return AVURLAsset(url: missingMediaURL)
    }
    
    fileprivate func tryLoadAssetAtResolvedURL(url:URL) -> AVURLAsset
    {
        // do some very simple semantics to see if theres a chance we can load the asset
        
        let supported:Bool
        
        switch url.pathExtension
        {
        case "mp4":
            supported = true
        case "mov":
            supported = true
        case "m4v":
            supported = true
        case "mxf":
            supported = true
            
            
        case "m4a":
            supported = true
        case "mp3":
            supported = true
        case "aiff":
            supported = true
        case "wav":
            supported = true

            
        default:
            supported = false
        }
       
        if supported
        {
            return AVURLAsset(url: url)
        }
        
        let notSupportedMedia = Bundle.main.url(forResource: "MediaNotSupported", withExtension: "mp4")!
        
        return AVURLAsset(url: notSupportedMedia)

    }
    
}

