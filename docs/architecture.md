# VisionKit Lab Architecture

Apple [VisionKit](https://developer.apple.com/documentation/visionkit) provides three main UI surfaces for recognizing content. This lab implements all three.

## VisionKit surfaces

| Screen | API | Apple topic |
|--------|-----|-------------|
| **Live Text** | `ImageAnalyzer` + `ImageAnalysisInteraction` | [Enabling Live Text interactions with images](https://developer.apple.com/documentation/visionkit/enabling-live-text-interactions-with-images) |
| **Data Scanner** | `DataScannerViewController` | [Scanning data with the camera](https://developer.apple.com/documentation/visionkit/scanning-data-with-the-camera) |
| **Document Camera** | `VNDocumentCameraViewController` | [Document scanning through the camera](https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller) |

### Live Text

- Check `ImageAnalyzer.isSupported` (A12 Bionic or later).
- Analyze with `ImageAnalyzer.Configuration([.text, .machineReadableCode])`.
- Attach `ImageAnalysisInteraction` to a `UIImageView` and set `analysis`.

### Data Scanner

- Check `isSupported` and `isAvailable` before `startScanning()`.
- Requires `NSCameraUsageDescription`.
- Delegate receives add/remove/update and `didTapOn` for recognized items.

### Document Camera

- Check `VNDocumentCameraViewController.isSupported`.
- Returns all pages from `VNDocumentCameraScan`.

Camera features need a physical device. Live Text works on supported devices with photos from the library.

## Testing

`HomeDestinationTests` — navigation identifiers and feature list.
