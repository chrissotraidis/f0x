#!/usr/bin/env swift

import AVFoundation
import CoreVideo
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("usage: analyze-metal-capture.swift <capture.mov>\n", stderr)
    exit(2)
}

let path = CommandLine.arguments[1]
let asset = AVURLAsset(url: URL(fileURLWithPath: path))
guard let track = try await asset.loadTracks(withMediaType: .video).first else {
    fputs("capture has no video track: \(path)\n", stderr)
    exit(2)
}

let reader = try AVAssetReader(asset: asset)
let output = AVAssetReaderTrackOutput(
    track: track,
    outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
)
reader.add(output)
guard reader.startReading() else {
    fputs("could not read capture: \(reader.error?.localizedDescription ?? "unknown error")\n", stderr)
    exit(2)
}

var lumas: [Double] = []
var blackFractions: [Double] = []
var adjacentDifferences: [Double] = []
var timestamps: [Double] = []
var previousSamples: [UInt8]?

while let sample = output.copyNextSampleBuffer(),
      let pixelBuffer = CMSampleBufferGetImageBuffer(sample) {
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let base = CVPixelBufferGetBaseAddress(pixelBuffer)!.assumingMemoryBound(to: UInt8.self)
    let xStart = width / 16
    let xEnd = width * 15 / 16
    let yStart = height / 16
    let yEnd = height * 15 / 16

    var sum = 0.0
    var sampleCount = 0
    var blackCount = 0
    var currentSamples: [UInt8] = []

    for y in Swift.stride(from: yStart, to: yEnd, by: 16) {
        for x in Swift.stride(from: xStart, to: xEnd, by: 16) {
            let pixel = base + y * rowBytes + x * 4
            let red = Int(pixel[2]) * 54
            let green = Int(pixel[1]) * 183
            let blue = Int(pixel[0]) * 19
            let luma = UInt8((red + green + blue) >> 8)
            currentSamples.append(luma)
            sum += Double(luma)
            sampleCount += 1
            if luma < 5 {
                blackCount += 1
            }
        }
    }

    lumas.append(sum / Double(sampleCount))
    blackFractions.append(Double(blackCount) / Double(sampleCount))
    timestamps.append(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sample)))

    if let previousSamples {
        var difference = 0.0
        for index in currentSamples.indices {
            difference += abs(Double(currentSamples[index]) - Double(previousSamples[index]))
        }
        adjacentDifferences.append(difference / Double(currentSamples.count))
    }
    previousSamples = currentSamples
}

guard !lumas.isEmpty else {
    fputs("capture contained no decoded frames: \(path)\n", stderr)
    exit(2)
}

let duration = (timestamps.last ?? 0) - (timestamps.first ?? 0)
let nearBlackFrames = lumas.filter { $0 < 8 }.count
let brightnessJumps = adjacentDifferences.filter { $0 > 20 }.count
print("capture=\(path)")
print("frames=\(lumas.count) duration_seconds=\(String(format: "%.3f", duration))")
print("mean_luma_min=\(String(format: "%.2f", lumas.min() ?? 0)) mean_luma_max=\(String(format: "%.2f", lumas.max() ?? 0))")
print("max_black_fraction=\(String(format: "%.4f", blackFractions.max() ?? 0)) near_black_frames=\(nearBlackFrames)")
print("max_adjacent_difference=\(String(format: "%.2f", adjacentDifferences.max() ?? 0)) brightness_jumps=\(brightnessJumps)")

for index in lumas.indices where lumas[index] < 8 ||
    (index > 0 && adjacentDifferences[index - 1] > 20) {
    let difference = index > 0 ? String(format: "%.2f", adjacentDifferences[index - 1]) : "n/a"
    print(
        "event frame=\(index) time=\(String(format: "%.3f", timestamps[index])) " +
        "mean_luma=\(String(format: "%.2f", lumas[index])) " +
        "black_fraction=\(String(format: "%.4f", blackFractions[index])) " +
        "adjacent_difference=\(difference)"
    )
}

if reader.status == .failed {
    fputs("capture decode failed: \(reader.error?.localizedDescription ?? "unknown error")\n", stderr)
    exit(2)
}

exit(nearBlackFrames == 0 && brightnessJumps == 0 ? 0 : 1)
