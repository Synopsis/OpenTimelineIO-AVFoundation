# OpenTimelineIO-AVFoundation

<div align="center">
<img width="256" alt="OTIO Reader Icon" src="https://github.com/user-attachments/assets/f8fa96f7-06da-45c9-a00e-62c5d3e57377" align="center">
<img width="1141" alt="image" src="https://github.com/user-attachments/assets/fbf16b05-7495-4299-bd21-2d563d9f5aaf", align="center">
            <div>
                        Realtime playback of OpenTimelineIO files with the sample app OpenTimelineIO Reader:
            </div>
</div>

            
## Note

This library is under heavy development!

## General

This Swift Package extends [OpenTimelineIO's Swift Bindings](https://github.com/openTimelineIO/OpenTimelineIO-Swift-Bindings/)  to provide  functionality for Apple platforms. 

The goal is to enable easy interoperability OpenTimelineIO and AVFoundation objects in a correct, lossless and useful manner to enable real world workflows.

* Load OpenTimeline IO files into OTIO `Timeline` objects and introspect using the standard Swift bindings.
* Create  AVFoundation `AVComposition` `AVVideoComposition` and `AVAudioMix` objects from an OTIO `Timeline` instance allowing for playback via `AVPlayer` and export via `AVExportSession` or `AVAssetWriter` to Quicktime compatible file formats.
* Convert your own edits as `AVMutableCompositions` into a OTIO `Timeline`

This library should be compatible with the following Apple platforms:

* macOS
* iOS
* visionOS

but to date has only been extensively tested on macOS

## Quickstart for Users

* Download [the latest release of the OpenTimelineIO Reader](https://github.com/Synopsis/OpenTimelineIO-AVFoundation/releases).
* The app should register itself as a reader of OTIO files. 
    * In theory should be able to double click a `.otio` file which will launch the app, or control click with open as. 
* To ensure the widest media support possible, please make sure to install [Apple's Pro Video Formats](https://support.apple.com/en-us/106396) package. 
    * If you have Final Cut Pro X, Compressor or Motion, this step is unnecessary.
    * Please note that not all video formats are supported, not are image sequences. See [Video Format Compatibilty](#video-format-compatibility)

* Thats it!  

## Quicktart for Developers: 

### OpenTimelineIO to AVFoundation:

Assuming you have a basic `AVPlayer` setup, this will let you import a `.otio` file with basic jump cut editing.
See roadmap for transitions / effects.

```swift
    do {
        if
            let timeline = try Timeline.fromJSON(url: url) as? Timeline,
            let (composition, videoComposition, audioMix) = try await timeline.toAVCompositionRenderables()
        {
            let playerItem = AVPlayerItem(asset: composition)
            playerItem.videoComposition = videoComposition
            playerItem.audioMix = audioMix
            
            self.player.replaceCurrentItem(with: playerItem)
        }
    }
    catch
    {
        print(error)
    }
```

### AVFoundation to OpenTimelineIO:

Assuming you have succssfuly created an `AVCompostion` - this will export a basic `.otio` file without effects or transition metadata.
See roadmap for transitions / effects.


```swift
    do {
        let timeline = try compositon.toOTIOTimeline(named: toURL.lastPathComponent)
        try timeline.toJSON(url: toURL)
    }
    catch
    {
        print(error)
    }
```

### OpenTimelineIO Extensions

- Conversion of OpenTimelineIO `RationalTime` to CoreMedia `CMTime`
- Conversion of OpenTimelineIO `TimeRange` to CoreMedia `CMTimeRange`
- Conversion of OpenTimelineIO `ExternalReference` to AVFoundation `AVAsset`
- Conversion of OpenTimelineIO `Timeline` to playable/exportable AVFoundation `AVCompostion` `AVVideoCompostion` and `AVAudioMix` 

### Core Media Extensions

- Conversion of CoreMedia `CMTime` to OpenTimelineIO `RationalTime`
- Conversion of CoreMedia `CMTimeRange` to OpenTimelineIO `TimeRange`

### AVFoundation Extensions

- Conversion of `AVCompositionTrackSegment` to OpenTimelineIO `Clip` with an embedded OpenTimelineIO `ExternalReference` which has url metadata
- Conversion of `AVCompositionTrack` to OpenTimelineIO `Track` with each `AVCompositionTrackSegment` converted to OpenTimelineIO `Clip` associations
- Conversion of `AVComposition` to OpenTimelineIO `Timeline` with associated `Tracks` converted

## Compatibility: 

### OTIO Format Compatibility Matrix

| OTIO Formats | Status | Notes |
-- | -- | -- 
|OTIO| :white_check_mark:| |
|OTIOD | :white_check_mark:| | 
|OTIOZ | :x: | Planned|

### NLE Compatibility

| NLE | Import from NLE | Export to NLE | 
-- | -- | ---
| Davinci Resolve 18.6| :white_check_mark: | :white_check_mark: |
| Davinci Resolve 19 | :white_check_mark: | :white_check_mark: |


### Project Validation

| Sample Project | Import to AVFoundation | Export from AVFoundation 
-- | -- | --
| [ALab Trailer](https://dpel.aswf.io/alab-trailer/) |  :white_check_mark: | :white_check_mark: 
| [AWS Picchu Edit](https://dpel.aswf.io/aws-picchu-edit/) | :white_check_mark: (Decompress .otioz zip file and open the bundled .otio file) | :white_check_mark: 
| [OTIO-OC-Examples](https://github.com/darbyjohnston/otio-oc-examples) |  :white_check_mark:  | :white_check_mark:

### Video Format Compatibility

Generally if Quicktime or Final Cut Pro X Can support it, it should just work.

| Video Formats | Status | Notes 
-- | -- | -- 
| H.264 | :white_check_mark: | Native |
| HEVC | :white_check_mark: | Native |
| Apple ProRes | :white_check_mark: | Requires [Apple Pro Video Formats](https://support.apple.com/kb/DL2100?locale=en_US) for some variants | 
| Apple Intermediate Codec | :white_check_mark: | Requires [Apple Pro Video Formats](https://support.apple.com/kb/DL2100?locale=en_US) for some variants
| MXF wrapped Pro Res | :white_check_mark: | For developers: Requires  `MTRegisterProfessionalVideoWorkflowFormatReaders()` and `VTRegisterProfessionalVideoWorkflowVideoDecoders()`  to be enabled|
| MXF Wrapped DNx | :white_check_mark: | Requires [Apple Pro Video Formats](https://support.apple.com/kb/DL2100?locale=en_US) for Avid DNxHD® / Avid DNxHR®. For developers: Requires `MTRegisterProfessionalVideoWorkflowFormatReaders()` and `VTRegisterProfessionalVideoWorkflowVideoDecoders()`  to be enabled - only some DNx variants work: | 
| MXF Wrapped DNxHD_36 | :white_check_mark: | |
| MXF Wrapped DNxHD_80 | :warning: | (codec specifically gets subsampled down to 1440 x 1080)|
| MXF Wrapped DNxHD_115 | :white_check_mark:| |
| MXF Wrapped DNxHD_175 | :white_check_mark:| |
| MXF Wrapped DNxHR_SQ | :white_check_mark:| |
| MXF Wrapped DNxHR_LB | :white_check_mark:| |
| MXF Wrapped DNxHR_HQ | :white_check_mark:| |
| Image Frames | :x: | Requires custom compositor | 
| Image Sequences | :x: | Requires custom compositor| 
| Raw Formats (BRaw, Red, etc) | :x: | Requires you to have SDK - manage decode and roll your own custom compositor | 

## Dependencies

- [OpenTimelineIO's Swift Bindings](https://github.com/openTimelineIO/OpenTimelineIO-Swift-Bindings/) for Swift interoperabiloty
- [TimecodeKit](https://github.com/orchetect/TimecodeKit) for reading and parsing Time Code from AVAsset's

## Roadmap

- Enable viable metadata from `AVAssets` to `ExternalRefernce` and other objects where appropriate to faciliate correctness and robustness in conversion.
    - Waiting on [#51](https://github.com/OpenTimelineIO/OpenTimelineIO-Swift-Bindings/issues/51)

- Enable robust support for transitions / effects metadata to be passed between AVFoundation and OTIO
    - This requires thinking deeply how to support transitions and effects, and the infrasturcture required (custom instructions, composition renderers, etc).
    - Input welcome!

## FAQ

* Why does RationalTime seconds, rate and value differ from a converted CMTIme?

RationalTime uses double as numerator and denimonator for rational time calculations. CMTime uses Int64 and Int32 for its value and time base. In order to get most accurate conversions, OpenTimleineIO-AVFoundation uses looks at the number of decimal places in a RationalTime representation and scales it to a whole number to maximally represent the same ratio without rounding or truncating which would happen with naive `Double` <-> `Int` casting. 

See our Unit tests for conversion notes. In general, for integer frame rates (ie 120, 60, 30, 25, 24) there is zero loss conversions. For non integer frame rates like 59.97, 29.97, 24.98 (23.976) there may be very minor differences in the conversions as of today (our Unit testing uses an accuracy factor of `0.00000000001` )

If you have ideas on lossless conversion, PR's are welcome! This was a first pass :)


## Credits:

OpenTimelineIO and TimecodeKit, and Ozu.ai for supporting this effort.
