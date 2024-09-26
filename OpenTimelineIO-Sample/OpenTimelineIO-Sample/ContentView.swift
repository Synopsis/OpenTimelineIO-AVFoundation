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
    var fileURL:URL?
    
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
                    print("Export")
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(document: .constant(OpenTimelineIO_SampleDocument()))
}
