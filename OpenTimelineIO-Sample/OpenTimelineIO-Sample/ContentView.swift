//
//  ContentView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/26/24.
//

import SwiftUI
import AVKit

struct ContentView: View
{
    @Binding var document: OpenTimelineIO_SampleDocument

    // This is beyond lame that I need this in the view!?
    var fileURL:URL?
    
    @State private var isExporting: Bool = false

    init(document:   Binding<OpenTimelineIO_SampleDocument>  , fileURL: URL? = nil) {
        self._document = document
        self.fileURL = fileURL
    
        guard let fileURL = fileURL else { return }
       
        self.$document.wrappedValue.setupPlayerWithBaseDocumentURL(fileURL)        
    }
    
    var body: some View {

        VStack {
            Text(fileURL?.absoluteString ?? "No File URL")
            VideoPlayer(player: document.player)
            
            HStack
            {
                Button("Export", role: .none) {
                    print("Export start")
                    self.isExporting.toggle()
                }
                
                
                .fileExporter(isPresented: $isExporting,
                              document: document,
                              contentType: .mpeg4Movie,
                              defaultFilename: document.timeline.name) { result in
                             
                  switch result {
                  case .success(let url):
                      print("saved to \(url)")
                  case .failure(let error):
                    print(error)
                  }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(document: .constant(OpenTimelineIO_SampleDocument()))
}
