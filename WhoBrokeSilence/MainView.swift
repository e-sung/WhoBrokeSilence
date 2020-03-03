//
//  MainView.swift
//  WhoBrokeSilence
//
//  Created by 류성두 on 2020/03/03.
//  Copyright © 2020 류성두. All rights reserved.
//

import SwiftUI
import SoundRecognizer

class MainViewModel: ObservableObject {
    let soundRecognizer = SoundeRecornizer()
    @Published var currentSoundLevel: Float = 0
    init() {
        soundRecognizer.audioLevelHandler = { level in
            DispatchQueue.main.async {
                self.currentSoundLevel = level
            }
        }
        soundRecognizer.startListening()
    }
}


struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    @ObservedObject var dragCircleViewModel = DragCircleViewModel.shared
    let maxSize = UIScreen.main.bounds.size.width
    var noiseLevel: CGFloat {
        CGFloat(viewModel.currentSoundLevel)
    }
    var noiseCircleRadius:CGFloat {
        noiseLevel * UIScreen.main.bounds.width * 3
    }
    
    let dragCircle = DraggableCircle()
    
    var dragCircleColor: Color {
        if dragCircleViewModel.dragCircleRadius > noiseCircleRadius {
            print(dragCircleViewModel.dragCircleRadius)
            return .green
        }
        else {
            return .red
        }
    }

    var body: some View {
        ZStack {
            Circle().frame(width: self.noiseCircleRadius,
                           height: self.noiseCircleRadius,
                           alignment: .center)
                .foregroundColor(.gray)
                .animation(Animation.easeInOut)
            
            self.dragCircle
                .foregroundColor(self.dragCircleColor)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
