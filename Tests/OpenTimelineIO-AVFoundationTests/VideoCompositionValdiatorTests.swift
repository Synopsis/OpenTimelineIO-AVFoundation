//
//  VideoCompositionValdiator.swift
//
// SPDX-License-Identifier: Apache-2.0
// Copyright Contributors to the OpenTimelineIO project

import XCTest
@testable import OpenTimelineIO_AVFoundation
@testable import OpenTimelineIO

import Foundation
import CoreMedia
import AVFoundation

class VideoCompositionValdiatorTests: XCTestCase
{
    // This is admittedly sort of dumb
    func testValidator()
    {
        let validator = VideoCompositionValidator()
        
        let comp = AVMutableComposition()
        let videoComp = AVMutableVideoComposition()
        let instruction = AVMutableVideoCompositionInstruction()
        let layerInstruction = AVMutableVideoCompositionLayerInstruction()

        var t = validator.videoComposition(videoComp, shouldContinueValidatingAfterFindingEmptyTimeRange: CMTimeRange.zero)
        XCTAssertEqual(t, true)

        t = validator.videoComposition(videoComp, shouldContinueValidatingAfterFindingInvalidValueForKey: "BAD KEY")
        XCTAssertEqual(t, false)

        t = validator.videoComposition(videoComp, shouldContinueValidatingAfterFindingInvalidTimeRangeIn: instruction)
        XCTAssertEqual(t, false)

        t = validator.videoComposition(videoComp, shouldContinueValidatingAfterFindingInvalidTrackIDIn:instruction, layerInstruction: layerInstruction, asset: comp)
        XCTAssertEqual(t, false)

    }
}
