//
//  OpenTimelineIO_SampleApp.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/26/24.
//

import SwiftUI
import MediaToolbox
import VideoToolbox

@main
struct OpenTimelineIO_SampleApp: App {
    
    init()
    {
        MTRegisterProfessionalVideoWorkflowFormatReaders()
        VTRegisterProfessionalVideoWorkflowVideoDecoders()
        VTRegisterProfessionalVideoWorkflowVideoEncoders()
        VTRegisterSupplementalVideoDecoderIfAvailable(kCMVideoCodecType_AV1)
        VTRegisterSupplementalVideoDecoderIfAvailable(kCMVideoCodecType_VP9)
    }
    
    var body: some Scene
    {
        DocumentGroup(newDocument: OpenTimelineIO_SampleDocument()) { file in
            ContentView(document: file.$document, fileURL: file.fileURL)
        }
    }
}
