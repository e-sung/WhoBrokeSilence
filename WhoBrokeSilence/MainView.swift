//
//  MainView.swift
//  WhoBrokeSilence
//
//  Created by 류성두 on 2020/03/03.
//  Copyright © 2020 류성두. All rights reserved.
//

import SwiftUI
import SoundRecognizer
import Combine
import AVFoundation

class MainViewModel: ObservableObject {
    let soundRecognizer = SoundeRecornizer()
    @Published var currentSoundLevel: Float = 0
    @Published var noiseCount:Int = 0
    @Published var noiseCircleRadius:CGFloat = 150
    @Published var dragCircleColor:Color = .green
    @Published var noiseLevelString:String = ""
    @Published var burstPerMinute:Int = 0
    var backgroundColor: Color {
        if noiseCircleRadius < DragCircleViewModel.shared.dragCircleRadius {
            return .white
        }
        return .red
    }
    var textColor: Color {
        if noiseCircleRadius < DragCircleViewModel.shared.dragCircleRadius {
            return .black
        }
        return .white
    }
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    var threshHoldBPM = 20
    var cancelBag:[Cancellable] = []
    var noiseNumberFormatter:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    init() {
        soundRecognizer.audioLevelHandler = { level in
            DispatchQueue.main.async {
                self.currentSoundLevel = level
            }
        }
        soundRecognizer.startListening()
        
        let soundLevelToCircleRadiusBinding =
            $currentSoundLevel
                .map { CGFloat($0 )}
                .map { $0 * UIScreen.main.bounds.width * 1.5}
                .assign(to: \.noiseCircleRadius, on: self)
        cancelBag.append(soundLevelToCircleRadiusBinding)
        
        let circleRadiusToColorBinding = $noiseCircleRadius
            .map { radius -> Color in
                let draggableCircleRadius = DragCircleViewModel.shared.dragCircleRadius
                if radius > draggableCircleRadius {
                    self.burstPerMinute += 1
                    return .red
                }
                return .green
            }
        .assign(to: \.dragCircleColor, on: self)
        cancelBag.append(circleRadiusToColorBinding)
        
        let soundLevelToString = $currentSoundLevel
            .map { $0 * 100 }
            .map { NSNumber(value: $0) }
            .compactMap { self.noiseNumberFormatter.string(from: $0) }
            .map({ $0 + "dB"})
            .assign(to: \.noiseLevelString, on: self)
        cancelBag.append(soundLevelToString)
        
        let bpmResetTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            self.burstPerMinute = 0
        })
        bpmResetTimer.fire()
        
        let bpmToUtter = $burstPerMinute
            .filter({ self.threshHoldBPM < $0 })
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                self.burstPerMinute = 0
                let utterance = AVSpeechUtterance(string: "저기이... 정말 죄송하지만... 좀 조용히 해주시겠어요?")
                utterance.voice = AVSpeechSynthesisVoice(language:"ko-kr")
                self.speechSynthesizer.speak(utterance)

            })
        
        cancelBag.append(bpmToUtter)

    }
    
    private func resetBsPerMinuteEveryMinute() {
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { timer in
            self.noiseCount = 0
        })
        timer.fire()
    }
    
}


struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    @ObservedObject var dragCircleViewModel = DragCircleViewModel.shared
    let maxSize = UIScreen.main.bounds.size.width
    
    let dragCircle = DraggableCircle()

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Circle().frame(width: self.viewModel.noiseCircleRadius,
                               height: self.viewModel.noiseCircleRadius,
                               alignment: .center)
                    .foregroundColor(.gray)
                    .animation(Animation.easeInOut)
                Text(viewModel.noiseLevelString).font(Font.monospacedDigit(.headline)())
                
                self.dragCircle
                    .foregroundColor(self.viewModel.dragCircleColor)
                VStack {
                    Spacer()
                    Text("지난 1분동안 떠든 횟수 \(self.viewModel.burstPerMinute) 회")
                        .font(Font.monospacedDigit(Font.body)())
                        .foregroundColor(self.viewModel.textColor)
                    Spacer().frame(height:40)
                }
            }
            Spacer()
        }.background(viewModel.backgroundColor)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
