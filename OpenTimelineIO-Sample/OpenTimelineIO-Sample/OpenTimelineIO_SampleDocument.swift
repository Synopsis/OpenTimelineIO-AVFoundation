//
//  OpenTimelineIO_SampleDocument.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/26/24.
//

import SwiftUI
import UniformTypeIdentifiers
import OpenTimelineIO
import OpenTimelineIO_AVFoundation
import AVFoundation

extension UTType
{
    static var openTimelineIO: UTType
    {
        UTType(importedAs: "io.aswf.opentimelineio")
    }
}

class OpenTimelineIO_SampleDocument: FileDocument
{
    var player = AVPlayer()
    var timeline:Timeline
    var fileURL:URL? = nil
    
    init()
    {
        self.timeline = Timeline(name: "Untitled OpenTimelineIO Timeline")
    }

    static var readableContentTypes: [UTType] { [.openTimelineIO] }
    static var writableContentTypes: [UTType] { [.mpeg4Movie, .quickTimeMovie] }
    
    required init(configuration: ReadConfiguration) throws
    {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8),
              let timeline = try Timeline.fromJSON(string:string) as? Timeline
        else
        {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.timeline = timeline
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        switch configuration.contentType
        {
        case .openTimelineIO:
            return try self.saveAsOTIO()
            
        case .mpeg4Movie:
            let url = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .mpeg4Movie)
            self.setupPlayerWithBaseDocumentURL(url)
             return try .init(url: url)
 
        default:
            throw CocoaError(.fileWriteUnknown)
        }
        
    }
    
    private func saveAsOTIO() throws -> FileWrapper
    {
        let string = try self.timeline.toJSON()
        let data = string.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    func setupPlayerWithBaseDocumentURL(_ url:URL)
    {
        Task
        {
            do
            {
                if let (composition, videoComposition, audioMix) = try await self.timeline.toAVCompositionRenderables(baseURL: url.deletingLastPathComponent())
                {
                    let playerItem = await AVPlayerItem(asset: composition)
                    playerItem.videoComposition = videoComposition
                    playerItem.audioMix = audioMix
                    
                    await MainActor.run {
                        self.player.replaceCurrentItem(with: playerItem)
                    }
                }
            }
            catch
            {
                print("Error creating composition from timeline: \(error)")
            }
                
        }
    }
    
    func exportToURL(url:URL)
    {
        if
            let currentItem = self.player.currentItem,
            let videoComposition = currentItem.videoComposition,
            let audioMix = currentItem.audioMix
        {
            let composition = currentItem.asset
            
            let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.videoComposition = videoComposition
            exportSession?.audioMix = audioMix
            exportSession?.outputURL = url
            exportSession?.outputFileType = .mp4
            exportSession?.exportAsynchronously(completionHandler: {
                NSWorkspace.shared.open(url)
            })
        }
    }
}
