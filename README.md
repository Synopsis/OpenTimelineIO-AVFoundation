# OpenTimelineIO-AVFoundation

## Note

This library is under heavy development!

## General

This Swift Package extends [OpenTimelineIO's Swift Bindings](https://github.com/openTimelineIO/OpenTimelineIO-Swift-Bindings/)   to provide isolated functionality for Apple platforms. The goal is to enable easy interchange between OpenTimelineIO and AVFoundation objects in a correct, lossless and useful manner.

This library should be compatible with the following Apple platforms:

* macOS
* iOS
* visionOS

but to date has only been extensively tested on macOS

## Core Media Extensions

See `CoreMedia.swift` for the extensions enabling:

- Conversion of CoreMedia `CMTime` to OpenTimelineIO `RationalTime`
- Conversion of CoreMedia `CMTimeRange` to OpenTimelineIO `TimeRange`
- Conversion of OpenTimelineIO `RationalTime` to CoreMedia `CMTime`
- Conversion of OpenTimelineIO `TimeRange` to CoreMedia `CMTimeRange`

## AVFoundation Extensions

See `AVFoundation.swift` for the extensions enabling:

- Conversion of `AVCompositionTrackSegment` to OpenTimelineIO `Clip` with an embedded OpenTimelineIO `ExternalReference` which has url metadata
- Conversion of `AVCompositionTrack` to OpenTimelineIO `Track` with track segments converted to OpenTimelineIO `Clip` associations
- Conversion of `AVComposition` to OpenTimelineIO `Timeline` with associated `Tracks` converted

## Dependencies

- [OpenTimelineIO's Swift Bindings](https://github.com/openTimelineIO/OpenTimelineIO-Swift-Bindings/) for Swift interoperabiloty
- TimecodeKit for reading and parsing Time Code from AVAsset's

## Roadmap

- Enable viable metadata from `AVAssets` to `ExternalRefernce` and other objects where appropriate to faciliate correctness and robustness in conversion.

- Enable conversion from an OpenTimelineIO `Timeline` into a playable custom `AVComposition` asset.
    - This requires thinking deeply how to support transitions and effects, and the infrasturcture required (custom instructions, composition renderers, etc).
    - The first attempt will mostly likely only implement standard cuts
    - This would require mirroring the AVFoundation conversion, so `Track` `Clips` and `ExternalReference` can be converted to `AVCompositionTracks` `AVCompositionTrackSegments` and `AVURLAssets`
    - Input welcome!
    
- Leverage TimecodeKit to enable Asset reading of TimeCode values and populating our OpenTimelineIO `RationalTimes` with Timecode Offsets as per best practice.

- Follow a best practices guide to facilitate export


## FAQ

* Why does RationalTime seconds, rate and value differ from a converted CMTIme?

RationalTime uses double as numerator and denimonator for rational time calculations. CMTime uses Int64 and Int32 for its value and time base. In order to get most accurate conversions, OpenTimleineIO-AVFoundation uses looks at the number of decimal places in a RationalTime representation and scales it to a whole number to maximally represent the same ratio without rounding or truncating which would happen with naive `Double` <-> `Int` casting. 

See our Unit tests for conversion notes. In general, for integer frame rates (ie 120, 60, 30, 25, 24) there is zero loss conversions. For non integer frame rates like 59.97, 29.97, 24.98 (23.976) there may be very minor differences in the conversions as of today (our Unit testing uses an accuracy factor of `0.00000000001` )

If you have ideas on lossless conversion, PR's are welcome! This was a first pass :)


## Credits:

OpenTimelineIO of course, and Ozu.ai for supporting this effort.
