//
//  ItemInspectorView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/28/24.
//

import SwiftUI
import OpenTimelineIO

struct ItemInspectorView: View {
    @Binding var selectedItem: Item?
    
    @State var jsonExpanded: Bool = false
    
    var body: some View
    {
        if let selectedItem = self.selectedItem
        {
            List()
            {
                Section(header: Text("General") )
                {
                    self.inspectorEntry(header: "Type:", value: selectedItem.schemaName)
                    
                    self.inspectorEntry(header: "Name:", value: selectedItem.name)
                }
                
                if let clip = selectedItem as? Clip,
                   let mediaReference = clip.mediaReference as? ExternalReference
                {
                    Section(header: Text("Media Reference") )
                    {
                        self.inspectorEntry(header: "Target URL:", value: mediaReference.targetURL ?? "No Target URL" )
                    }
                }

                Section(header: Text("Timing") )
                {
                    
                    self.inspectorEntry(header: "Duration Seconds:", value: self.safeDurationSeconds(item: selectedItem))

                    self.inspectorEntry(header: "Duration Frames:", value: self.safeDurationTimeCode(item: selectedItem) )

                    self.inspectorEntry(header: "Duration Value:", value: String( self.safeDurationValue(item: selectedItem) ) )

                    self.inspectorEntry(header: "Duration Rate:", value: String( self.safeDurationRate(item: selectedItem) ) )

                    self.inspectorEntry(header: "Available Range:", value: String( self.safeAvailableRange(item: selectedItem) ) )

                    self.inspectorEntry(header: "Trimmed Range:", value: String( self.safeTrimmedRange(item: selectedItem) ) )

                    self.inspectorEntry(header: "Visible Range:", value: String( self.safeVisibleRange(item: selectedItem) ) )

                }
                
                //if let metadata = selectedItem.metadata
                
                Section("JSON", isExpanded: self.$jsonExpanded)
                {
                    Text(self.safeToJSON(item: selectedItem))
                        .lineLimit(nil)
                        .textSelection(.enabled)
                        .font(.system(size: 10))
                }

            }
            .listStyle(.sidebar)
            .environment(\.sidebarRowSize, .small) 
            
        }
        else
        {
            Text("No item selected")
        }
    }
    
    func inspectorEntry(header:String, value:String) -> some View
    {
        HStack(alignment: .firstTextBaseline)
        {
            Text(header)
                .frame(minWidth: 90, alignment:.trailing)
            
            Text(value.trimmingCharacters(in: .whitespaces))
                .lineLimit(nil)
                .textSelection(.enabled)
        }
        .font(.system(size: 10))

    }
    
    func safeToJSON(item: Item) -> String
    {
        do {
            return try item.toJSON()
        }
        catch
        {
            return "Unable to serialize item: \(error)"
        }
    }
    
    func safeDurationSeconds(item: Item) -> String
    {
        do {
            return try item.duration().toTimestring()
        }
        catch
        {
            return "Unable to calculate duration: \(error)"
        }
    }
    
    func safeDurationTimeCode(item: Item) -> String
    {
        do {
            return try item.duration().toTimecode()
        }
        catch
        {
            return "Unable to calculate Timecode: \(error)"
        }
    }
    
    func safeDurationRate(item: Item) -> Double
    {
        do {
            return try item.duration().rate
        }
        catch
        {
            return .nan
        }
    }
    
    func safeDurationValue(item: Item) -> Double
    {
        do {
            return try item.duration().value
        }
        catch
        {
            return .nan
        }
    }
    
    func safeAvailableRange(item: Item) -> String
    {
        do {
            return try safeVisibleRangeTC(item: item)
        }
        catch
        {
            do {
                let range = try item.availableRange()
                return try range.startTime.toTimestring() + " - " + range.endTimeExclusive().toTimestring() + " s"
            }
            catch
            {
                return "Unable to Available Range: \(error)"
            }
        }
    }
    
    func safeAvailableRangeTC(item: Item) throws -> String
    {
        let range = try item.availableRange()
        return try range.startTime.toTimecode() + " - " + range.endTimeExclusive().toTimecode() + " F"
    }
    
    func safeTrimmedRange(item: Item) -> String
    {
        do {
            return try safeTrimmedRangeTC(item: item)
        }
        catch
        {
            do {
                let range = try item.trimmedRange()
                return try range.startTime.toTimestring() + " - " + range.endTimeExclusive().toTimestring() + " s"
            }
            catch
            {
                return "Unable to Trimmed Range: \(error)"
            }
        }
    }
    
    func safeTrimmedRangeTC(item: Item) throws -> String
    {
        let range = try item.trimmedRange()
        return try range.startTime.toTimecode() + " - " + range.endTimeExclusive().toTimecode() + " F"
    }
    
    func safeVisibleRange(item: Item) -> String
    {
        do {
            return try safeVisibleRangeTC(item: item)
        }
        catch
        {
            do {
                let range = try item.visibleRange()
                return  range.startTime.toTimestring() + " - " + range.endTimeExclusive().toTimestring() + " s"
            }
            catch
            {
                return "Unable to Visible Range: \(error)"
            }
        }
    }
    
    func safeVisibleRangeTC(item: Item) throws -> String
    {
        let range = try item.visibleRange()
        return try range.startTime.toTimecode() + " - " + range.endTimeExclusive().toTimecode() + " F"
    }
  
}
