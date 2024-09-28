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
    
    @State private var isExportingOTIO: Bool = false
    @State private var isExportingMPEG4: Bool = false
    @State var secondsToPixels = 10.0;
    
    init(document:   Binding<OpenTimelineIO_SampleDocument>  , fileURL: URL? = nil) {
        self._document = document
        self.fileURL = fileURL
    
        guard let fileURL = fileURL else { return }
       
        self.$document.wrappedValue.setupPlayerWithBaseDocumentURL(fileURL)        
    }
    
    var body: some View {

        VSplitView
        {
            VStack
            {
                Text(document.timeline.name.isEmpty ?  "Untitled Timeline" : document.timeline.name)
                    .padding()
                
                VideoPlayer(player: document.player)
            }
            
            VStack(alignment: .leading)
            {
                TimelineView(timeline: document.timeline, secondsToPixels: self.$secondsToPixels)
                
                HStack
                {
                    Button("Export OTIO", role: .none) {
                        print("Expor OTIO start")
                        self.isExportingOTIO.toggle()
                    }
                    
                    .fileExporter(isPresented: $isExportingOTIO,
                                  document: document,
                                  contentType: .openTimelineIO,
                                  defaultFilename: document.timeline.name) { result in
                                 
                      switch result {
                      case .success(let url):
                          print("saved to \(url)")
                      case .failure(let error):
                        print(error)
                      }
                    }
                    
                    
                    Button("Export Mpeg 4", role: .none) {
                        print("Export start")
                        
                        self.isExportingMPEG4.toggle()
                    }
                    
                    .fileExporter(isPresented: $isExportingMPEG4,
                                  document: VideoExportFile(),
                                  contentType: .mpeg4Movie,
                                  defaultFilename: document.timeline.name) { result in
                                 
                      switch result {
                      case .success(let url):
                          print("Exporting to \(url)")
                          document.exportToURL(url: url)
                          
                      case .failure(let error):
                        print(error)
                      }
                    }
                    
                    HStack {
                        Spacer()
                        Text("Zoom")
                            .lineLimit(1)
                            .font(.system(size: 10))
                        
                        Slider(value: $secondsToPixels, in: 10...300)
                            .controlSize(.mini)
                            .frame(width: 200)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
          
        }
    }
}

#Preview {
    ContentView(document: .constant(OpenTimelineIO_SampleDocument()))
}
