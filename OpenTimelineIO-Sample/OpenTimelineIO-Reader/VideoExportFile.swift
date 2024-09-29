//
//  Untitled.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/27/24.
//
import SwiftUI
import UniformTypeIdentifiers

struct VideoExportFile: FileDocument
{
    static var readableContentTypes: [UTType] { [.mpeg4Movie, .quickTimeMovie] }
    static var writableContentTypes: [UTType] { [.mpeg4Movie, .quickTimeMovie] }

    init() {}

    init(configuration: ReadConfiguration) throws {}

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        return FileWrapper()
    }
}
