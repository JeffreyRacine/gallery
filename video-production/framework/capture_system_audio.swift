import AVFoundation
import CoreMedia
import Foundation
import ScreenCaptureKit

final class SystemAudioRecorder: NSObject, SCStreamOutput, SCStreamDelegate {
    private let outputURL: URL
    private let stateLock = NSLock()
    private var audioFile: AVAudioFile?
    private(set) var buffersWritten = 0
    private(set) var writeError: Error?

    init(outputURL: URL) {
        self.outputURL = outputURL
    }

    func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of outputType: SCStreamOutputType
    ) {
        guard outputType == .audio, sampleBuffer.isValid else { return }

        stateLock.lock()
        defer { stateLock.unlock() }
        guard writeError == nil else { return }

        do {
            try sampleBuffer.withAudioBufferList { audioBufferList, _ in
                guard
                    let description = sampleBuffer.formatDescription?
                        .audioStreamBasicDescription,
                    let format = AVAudioFormat(
                        standardFormatWithSampleRate: description.mSampleRate,
                        channels: description.mChannelsPerFrame
                    ),
                    let pcmBuffer = AVAudioPCMBuffer(
                        pcmFormat: format,
                        bufferListNoCopy: audioBufferList.unsafePointer
                    )
                else {
                    throw NSError(
                        domain: "GallerySystemAudioCapture",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Unable to decode an audio sample buffer."]
                    )
                }

                if audioFile == nil {
                    audioFile = try AVAudioFile(
                        forWriting: outputURL,
                        settings: format.settings,
                        commonFormat: format.commonFormat,
                        interleaved: format.isInterleaved
                    )
                }
                try audioFile?.write(from: pcmBuffer)
                buffersWritten += 1
            }
        } catch {
            writeError = error
        }
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        stateLock.lock()
        if writeError == nil {
            writeError = error
        }
        stateLock.unlock()
    }
}

@main
struct CaptureSystemAudio {
    static func main() async throws {
        guard CommandLine.arguments.count == 3 else {
            FileHandle.standardError.write(
                Data("usage: capture_system_audio <duration-seconds> <output.caf>\n".utf8)
            )
            Foundation.exit(64)
        }

        guard
            let duration = Double(CommandLine.arguments[1]),
            duration > 0
        else {
            FileHandle.standardError.write(Data("duration must be positive\n".utf8))
            Foundation.exit(64)
        }

        let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: false
        )
        guard let display = content.displays.first else {
            throw NSError(
                domain: "GallerySystemAudioCapture",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No shareable display is available."]
            )
        }

        let filter = SCContentFilter(
            display: display,
            excludingApplications: [],
            exceptingWindows: []
        )
        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.excludesCurrentProcessAudio = true
        configuration.sampleRate = 48_000
        configuration.channelCount = 2
        configuration.width = 2
        configuration.height = 2
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 1)

        let recorder = SystemAudioRecorder(outputURL: outputURL)
        let stream = SCStream(filter: filter, configuration: configuration, delegate: recorder)
        let audioQueue = DispatchQueue(label: "gallery.system-audio.capture")
        try stream.addStreamOutput(recorder, type: .audio, sampleHandlerQueue: audioQueue)

        try await stream.startCapture()
        print("CAPTURE_READY duration=\(duration) output=\(outputURL.path)")
        fflush(stdout)

        try await Task.sleep(for: .seconds(duration))
        try await stream.stopCapture()
        audioQueue.sync {}

        if let writeError = recorder.writeError {
            throw writeError
        }
        guard recorder.buffersWritten > 0 else {
            throw NSError(
                domain: "GallerySystemAudioCapture",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Capture completed without audio buffers."]
            )
        }
        print("CAPTURE_COMPLETE buffers=\(recorder.buffersWritten) output=\(outputURL.path)")
    }
}
