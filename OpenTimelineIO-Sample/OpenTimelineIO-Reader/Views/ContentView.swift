//
//  ContentView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/26/24.
//

import OpenTimelineIO
import OpenTimelineIO_AVFoundation
import SwiftUI
import AVKit

struct ContentView: View
{
    @ObservedObject var document: OpenTimelineIO_ReaderDocument

    // This is beyond lame that I need this in the view!?
    var fileURL:URL?
    
    @State private var isExportingOTIO: Bool = false
    @State private var isExportingMPEG4: Bool = false
    @State var secondsToPixels = 10.0;
    
    
    //@State var inspectorOpen: Bool = true
    @State var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    @State var selectedItem: OpenTimelineIO.Item? = nil
    
    
    init(document: OpenTimelineIO_ReaderDocument  , fileURL: URL? = nil) {
        self.document = document
        self.fileURL = fileURL
        
        guard let fileURL = fileURL else { return }
        
        
       
        self.document.setupPlayerWithBaseDocumentURL(fileURL)
    }
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility)
        {
            EmptyView()
        }
        content:
        {
            VSplitView
            {
                VideoPlayer(player: document.player)
                
                VStack(alignment: .leading)
                {
                    Text(document.timeline.name.isEmpty ?  "Untitled Timeline" : document.timeline.name)
                        .padding(.horizontal)
                        .padding(.top, 5)

                    TimelineView(timeline: document.timeline,
                                 currentTime: self.$document.currentTime ,
                                 secondsToPixels: self.$secondsToPixels,
                                 selectedItem: self.$selectedItem)
                    
                    self.controlsViewStack()
                }
            }
        }
        detail: {
            ItemInspectorView(selectedItem: self.$selectedItem)
//                .inspectorColumnWidth(min: 250, ideal: 300, max: 500)
                .navigationSplitViewColumnWidth(min:250, ideal: 200, max: 300)

                .toolbar
                {
                    Spacer()
                    
                    Button {
                        if self.columnVisibility == .detailOnly {
                            self.columnVisibility = .doubleColumn
                        }
                        else
                        {
                            self.columnVisibility = .detailOnly
                        }
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            
        }
    }
    
    func controlsViewStack() -> some View {
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
                
                Slider(value: $secondsToPixels, in: 1...1000)
                    .controlSize(.mini)
                    .frame(width: 200)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView(document: OpenTimelineIO_ReaderDocument() )
}
