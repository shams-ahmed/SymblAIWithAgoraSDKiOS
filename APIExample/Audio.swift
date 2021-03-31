//
//  Audio.swift
//  APIExample
//
//  Created by Shams Ahmed on 29/03/2021.
//  Copyright © 2021 Agora Corp. All rights reserved.
//

import CoreAudio
import AVKit
import lame

/// Handle all audio observation
final class Audio {
    
    // MARK: - Property
    
    /// buffer for converting from raw PCM to MP3
    private var mp3Buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
    
    /// Helper to convert PCM to MP3
    private var lame: lame_t?
    
    /// Audio engine for iOS
    private let engine = AVAudioEngine()
    
    /// Size of each piece of data
    private let bufferSize: AVAudioFrameCount = 4096
    
    /// Check if audio recording is active
    var isRunning: Bool { engine.isRunning }
    
    /// Store for audio samples
    private(set) var data = NSMutableData()
    
    // MARK: - Init
    
    /// Create Audio controller and start the audio session
    init() {
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        
    }
    
    // MARK: - Audio
    
    /// Start listening to audio
    /// - Throws: errors trying to start audio connection
    func start() throws {
        print("Audio: starting up")
        
        let session = AVAudioSession.sharedInstance()
        
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            policy: .default,
            options: .defaultToSpeaker
        )
        
        try session.setActive(true)
        
        let node = engine.inputNode
        let bus = 0
        let input = node.inputFormat(forBus: bus)
        let output = node.outputFormat(forBus: bus)
        let sampleRate = Int32(input.sampleRate)
        
        lame = lame_init()
        lame_set_in_samplerate(lame, sampleRate / 2)
        lame_set_VBR(lame, vbr_default/*vbr_off*/)
        lame_set_out_samplerate(lame, 0) // which means LAME picks best value
        lame_set_quality(lame, 5); // normal quality, quite fast encoding
        lame_init_params(lame)
        
        // start the tap for input
        node.installTap(onBus: bus, bufferSize: bufferSize, format: output) { [weak self] buffer, _ in
            guard let self = self else { return print("Audio: failed to retain self") }
            guard let data = buffer.floatChannelData?[0] else {
                return print("Audio: Failed to find channel data")
            }
            
            self.process(data, forSize: buffer.frameLength)
        }
        
        try engine.start()
        
        print("Audio: started to listen for input")
    }
    
    /// Stop listening to audio
    /// - Throws: issues trying to close audio session
    /// - Returns: Raw mp3 data. Same as the data property
    func stop() throws -> Data {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        
        let session = AVAudioSession.sharedInstance()
        
        try session.setActive(false)
        
        print("Audio: stopped listening")
        
        return data as Data
    }
    
    // MARK: - Save
    
    /// Save audio to document folder
    /// - Parameter name: name of audio
    /// - Throws: issues with document folder permission
    /// - Returns: path of file
    func save(withName name: String) throws -> URL {
        var url = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        url.appendPathComponent("\(name).mp3")
            
        try data.write(to: url)
        
        print("Audio: Saved to: \(url.absoluteString)")
        
        return url
    }
    
    // MARK: - Process
    
    private func process(_ pointer: UnsafeMutablePointer<Float>, forSize size: AVAudioFrameCount) {
        /// encode PCM to mp3
        let frameLength = Int32(size) / 2
        let bytesWritten = lame_encode_buffer_interleaved_ieee_float(
            lame,
            pointer,
            frameLength,
            mp3Buffer,
            Int32(bufferSize)
        )
        
        data.append(mp3Buffer, length: Int(bytesWritten))
    }
}
