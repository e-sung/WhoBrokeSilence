//
//  SoundeRecornizer.swift
//  SDAudioEngine
//
//  Created by 류성두 on 2020/01/14.
//  Copyright © 2020 Sungdoo. All rights reserved.
//
import Foundation
import AVFoundation

public class SoundeRecornizer {
    private var audioEngine = AVAudioEngine()
    private var powerMeter = PowerMeter()
    public init() { }
    public var audioLevelHandler: (Float) -> Void = { _ in }
    

    public func startListening() {

        let inputNode = audioEngine.inputNode
        audioEngine.inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: inputNode.inputFormat(forBus: 0),
                             block: { [weak self] buffer, time in
                                guard let audioLevel = self?.powerMeter.audioLevel(of: buffer) else { return }
                                self?.audioLevelHandler(audioLevel)
                                
        })
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    public func stopListening() {
        audioEngine.stop()
    }
}
