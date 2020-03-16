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

class MainViewModel: ObservableObject {
    let soundRecognizer = SoundeRecornizer()
    @Published var currentSoundLevel: Float = 0
    @Published var noiseCount:Int = 0
    @Published var noiseCircleRadius:CGFloat = 150
    @Published var dragCircleColor:Color = .green
    var cancelBag:[Cancellable] = []
    
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
                .map { $0 * UIScreen.main.bounds.width * 3}
                .assign(to: \.noiseCircleRadius, on: self)
        cancelBag.append(soundLevelToCircleRadiusBinding)
        
        let circleRadiusToColorBinding = $noiseCircleRadius
            .map { radius -> Color in
                let draggableCircleRadius = DragCircleViewModel.shared.dragCircleRadius
                if radius > draggableCircleRadius {
                    return .red
                }
                return .green
            }
        .assign(to: \.dragCircleColor, on: self)
        
        cancelBag.append(circleRadiusToColorBinding)

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
        ZStack {
            Circle().frame(width: self.viewModel.noiseCircleRadius,
                           height: self.viewModel.noiseCircleRadius,
                           alignment: .center)
                .foregroundColor(.gray)
                .animation(Animation.easeInOut)
            
            self.dragCircle
                .foregroundColor(self.viewModel.dragCircleColor)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
