//
//  ItemInspectorView.swift
//  OpenTimelineIO-Sample
//
//  Created by Anton Marini on 9/28/24.
//

import SwiftUI
import OpenTimelineIO

struct ItemInspectorView: View
{
    // Need to conform to these protocols or else SwiftUI isnt happy
    struct SwiftUISafeKeyAndMetadataValueType : Hashable, Identifiable
    {
        static func == (lhs: ItemInspectorView.SwiftUISafeKeyAndMetadataValueType, rhs: ItemInspectorView.SwiftUISafeKeyAndMetadataValueType) -> Bool {
            
            return lhs.hashValue == rhs.hashValue
            
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }
        
        let id:String
        let key: String
        let value: (any MetadataValue)

        init(id:String, key: String, value: any MetadataValue) {
            self.id = id
            self.key = key
            self.value = value
        }
    }

    @Binding var selectedItem: Item?
    
    @State var jsonExpanded: Bool = false
    
    var body: some View
    {
        if let selectedItem = self.selectedItem
        {
            List()
            {
                Section(header: Text( "\(Image(systemName: "info.circle.fill")) General") )
                {
                    self.inspectorEntry(header: "Type", value: selectedItem.schemaName)
                    
                    self.inspectorEntry(header: "Name", value: selectedItem.name)
                }
                .listSectionSeparator(.hidden)

                if let clip = selectedItem as? Clip,
                   let mediaReference = clip.mediaReference as? ExternalReference
                {
                    Section(header: Text("\(Image(systemName: "film.circle.fill")) Media Reference") )
                    {
                        self.inspectorEntry(header: "Target URL", value: mediaReference.targetURL ?? "No Target URL" )
                    }
                    .listSectionSeparator(.hidden)
                }

                Section(header: Text("\(Image(systemName: "clock.fill")) Timing") )
                {
                    
                    self.inspectorEntry(header: "Duration Seconds", value: self.safeDurationSeconds(item: selectedItem))

                    self.inspectorEntry(header: "Duration Frames", value: self.safeDurationTimeCode(item: selectedItem) )

                    self.inspectorEntry(header: "Duration Value", value: String( self.safeDurationValue(item: selectedItem) ) )

                    self.inspectorEntry(header: "Duration Rate", value: String( self.safeDurationRate(item: selectedItem) ) )

                    self.inspectorEntry(header: "Available Range", value: String( self.safeAvailableRange(item: selectedItem) ) )

                    self.inspectorEntry(header: "Trimmed Range", value: String( self.safeTrimmedRange(item: selectedItem) ) )

                    self.inspectorEntry(header: "Visible Range", value: String( self.safeVisibleRange(item: selectedItem) ) )

                }
                .listSectionSeparator(.hidden)
                
                Section(header:Text("\(Image(systemName: "triangle.circle.fill")) Effects"))
                {
                    self.resursiveEffectViewBuilder(effects: selectedItem.effects)
                }
                .listSectionSeparator(.hidden)

                Section(header: Text("\(Image(systemName: "tag.circle.fill")) \(selectedItem.schemaName) Metadata") )
                {
                    self.resursiveMetadataViewBuilder(metadata: selectedItem.metadata)
                }
                .listSectionSeparator(.hidden)

                Section("\(Image(systemName: "gearshape.fill")) JSON")
                {
                    Text(self.safeToJSON(item: selectedItem))
                        .lineLimit(nil)
                        .textSelection(.enabled)
                        .font(.system(size: 10))
                }
                .listSectionSeparator(.hidden)

            }
            .controlSize(.mini)
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
            Text(header + ":")
                .bold()
                .frame(minWidth: 90, alignment:.trailing)
            
            Text(value.trimmingCharacters(in: .whitespaces))
                .lineLimit(nil)
                .textSelection(.enabled)
        }
        .font(.system(size: 10))
        .listRowSeparator(.hidden)

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
                return range.startTime.toTimestring() + " - " + range.endTimeExclusive().toTimestring() + " s"
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
                return range.startTime.toTimestring() + " - " + range.endTimeExclusive().toTimestring() + " s"
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
    
    func safeMetadata(metadata:OpenTimelineIO.Metadata.Dictionary) -> [ SwiftUISafeKeyAndMetadataValueType ]
    {
        var safeMetadata: [ SwiftUISafeKeyAndMetadataValueType ] = []
        
        for (index, (key, value)) in metadata.enumerated()
        {
            safeMetadata.append( SwiftUISafeKeyAndMetadataValueType(id:"\(index)-\(key)", key: key, value: value))
        }
        
        return safeMetadata
    }
        
    func safeVector(vector: OpenTimelineIO.Metadata.Vector) -> [SwiftUISafeKeyAndMetadataValueType]
    {
        var safeVector: [ SwiftUISafeKeyAndMetadataValueType ] = []

        for (index, vector) in vector.enumerated()
        {
            let id = "\(index)"
            let key =  "\(index)"
            
            safeVector.append( SwiftUISafeKeyAndMetadataValueType(id:id,  key: key, value: vector))
        }

        return safeVector
    }
    
    func safeEffects(effects: OpenTimelineIO.SerializableObject.Vector<OpenTimelineIO.Effect>) -> [SwiftUISafeKeyAndMetadataValueType]
    {
        var safeEffects: [ SwiftUISafeKeyAndMetadataValueType ] = []

        for (index, effect) in effects.enumerated()
        {
            let id = "\(index)-\(effect.name)-\(effect.effectName)"
            let key =  effect.name.isEmpty ? "\(index)" : "\(effect.name)"
            
            safeEffects.append( SwiftUISafeKeyAndMetadataValueType(id:id,  key: key, value: effect.metadata))
        }

        return safeEffects
    }
    
    func resursiveMetadataViewBuilder(metadata: OpenTimelineIO.Metadata.Dictionary, title:String = "Root" ) ->  AnyView
    {
        let safeMetadata = self.safeMetadata(metadata: metadata)
        
        return AnyView (
            DisclosureGroup(title)
            {
                ForEach(safeMetadata, id:\.self) { workAround in
                    
                    self.resursiveMetadataViewBuilder(workAround: workAround)
                }
            }
        )
    }
    
    func resursiveMetadataViewBuilder(vector: OpenTimelineIO.Metadata.Vector, title:String = "Vector" ) ->  AnyView
    {
        let safeVector = self.safeVector(vector: vector)
        
        return AnyView (
            DisclosureGroup(title)
            {
                ForEach(safeVector, id:\.self) { workAround in
                    
                    self.resursiveMetadataViewBuilder(workAround: workAround)
                }
            }
        )
    }
    
    func resursiveEffectViewBuilder(effects: OpenTimelineIO.SerializableObject.Vector<OpenTimelineIO.Effect>, title:String = "Effects" ) ->  AnyView
    {
        let safeMetadata = self.safeEffects(effects: effects)
        
        return AnyView (
            DisclosureGroup(title)
            {
                ForEach(safeMetadata, id:\.self) { workAround in
                    
                    self.resursiveMetadataViewBuilder(workAround: workAround)
                }
            }
        )
    }
    
    func resursiveMetadataViewBuilder(workAround: SwiftUISafeKeyAndMetadataValueType) ->  AnyView
    {
        let value = workAround.value
        let key = workAround.key

        switch value.metadataType
        {
        case .none:
            return AnyView( EmptyView() )
            
        case .bool:
            if let boolValue = value as? Bool {
                return  AnyView(  self.inspectorEntry(header: key , value: String(boolValue) ) )
            }
            
        case .int64:
            if let intValue = value as? Int64 {
                return AnyView(  self.inspectorEntry(header: key, value: String(intValue) ) )
            }
            
        case .double:
            if let doubleValue = value as? Double {
                return  AnyView( self.inspectorEntry(header: key, value: String(doubleValue) ) )
            }
            
        case .string:
            if let stringValue = value as? String {
                return  AnyView( self.inspectorEntry(header: key, value: stringValue ) )
            }
            
//        case .serializableObject:
//            <#code#>

        case .rationalTime:
            if let timeValue = value as? RationalTime {
                return AnyView( self.inspectorEntry(header: key, value: timeValue.toTimestring() ) )
            }
            
        case .timeRange:
            if let timeRange = value as? TimeRange {
                return AnyView( self.inspectorEntry(header: key, value: timeRange.startTime.toTimestring() + " - " + timeRange.endTimeExclusive().toTimestring( ) ) )
            }

//        case .timeTransform:
//            <#code#>

        case .dictionary:
            if let dictionary = value as? Metadata.Dictionary {
                return self.resursiveMetadataViewBuilder(metadata: dictionary, title: key)
            }
            
        case .vector:
            if let vector = value as? Metadata.Vector {
                return self.resursiveMetadataViewBuilder(vector: vector, title: key)
            }

//        case .unknown:
//            return AnyView (Text("Unknown)"))
            
        default:
            return AnyView ( EmptyView() )
            
            
        }
        
        return AnyView ( EmptyView() )

    }
    
  
}
