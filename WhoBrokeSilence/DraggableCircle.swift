//
//  ContentView.swift
//  WhoBrokeSilence
//
//  Created by 류성두 on 2020/03/03.
//  Copyright © 2020 류성두. All rights reserved.
//

import SwiftUI

class DragCircleViewModel: ObservableObject {
    static var shared = DragCircleViewModel()
    @Published var dragCircleRadius:CGFloat = 150
}

struct DraggableCircle: View {
    private let screenSize = UIScreen.main.bounds.size
    private var center: CGPoint {
        CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
    let minimumRadius: CGFloat = 100
    @ObservedObject var viewModel = DragCircleViewModel.shared
    var body: some View {
        Circle()
            .stroke(lineWidth: 4)
            .gesture(DragGesture(coordinateSpace:.global).onChanged({ r in
                let distance = r.location.distance(to: self.center)
                if distance * 2 < self.minimumRadius {
                    self.viewModel.dragCircleRadius = self.minimumRadius
                }
                else {
                    self.viewModel.dragCircleRadius = 2 * distance
                }
            }))
            .frame(width: viewModel.dragCircleRadius, height: viewModel.dragCircleRadius, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return DraggableCircle()
    }
}

extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: self, to: point))
    }
    
    private func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
}
