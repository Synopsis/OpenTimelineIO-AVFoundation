//
//  OTIOToAVFoundationTests.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project



import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class OTIOToAVFoundationTests: XCTestCase
{
    func testTimelineToComposition() async throws
    {
        let thisFile = URL(filePath: #file)
        let timelineURL = thisFile.deletingLastPathComponent().appending(component: "Assets/Timeline_23.98.otio")
        let timeline = try Timeline.fromJSON(url:timelineURL) as! Timeline

        let (composition, _, _) = try await timeline.toAVCompositionRenderables(baseURL: timelineURL.deletingLastPathComponent() )!

        let compositionDuration = composition.duration

        let timelineDuration = try timeline.duration()

        XCTAssertEqual(compositionDuration.seconds, timelineDuration.toSeconds(), accuracy: Self.accuracy)        
    }
    
    func testExternalReferencePath()
    {
        let thisFile = URL(filePath: #file)
        let testAsset1URL = thisFile.deletingLastPathComponent().appending(component: "Assets/OTIO Test Media 1 - 23.98.mp4")

        let reference = ExternalReference(targetURL: testAsset1URL.absoluteString )
        
        let asset = reference.toAVAsset()
        
        XCTAssertEqual(asset?.url.absoluteString, reference.targetURL)
    }
    
    func testExternalReferenceBaseURL()
    {
        let thisFile = URL(filePath: #file).deletingLastPathComponent()
        let fileName = "Assets/OTIO Test Media 1 - 23.98.mp4"
        let reference = ExternalReference(targetURL:fileName  )
        
        let asset = reference.toAVAsset(baseURL: thisFile)
        
        XCTAssertEqual(asset?.url.absoluteString, thisFile.appendingPathComponent(fileName).absoluteString)
    }
    
    func testExternalReferenceNoTargetURL()
    {
        let reference = ExternalReference()
        
        let asset = reference.toAVAsset()
        
        XCTAssertEqual(asset, nil)
    }
}
