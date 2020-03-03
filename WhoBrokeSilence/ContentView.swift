//
//  ContentView.swift
//  WhoBrokeSilence
//
//  Created by 류성두 on 2020/03/03.
//  Copyright © 2020 류성두. All rights reserved.
//

import SwiftUI

struct DraggableCircle: View {
    let screenSize = UIScreen.main.bounds.size
    var center: CGPoint {
        CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
    let minimumRadius: CGFloat = 100
    @State var radius: CGFloat
    var body: some View {
        Circle()
            .foregroundColor(/*@START_MENU_TOKEN@*/.green/*@END_MENU_TOKEN@*/)
            .gesture(DragGesture(coordinateSpace:.global).onChanged({ r in
                let distance = r.location.distance(to: self.center)
                if distance * 2 < self.minimumRadius {
                    self.radius = self.minimumRadius
                }
                else {
                    self.radius = 2 * distance
                }
            }))
            .frame(width: radius, height: radius, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return DraggableCircle(radius: 150)
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
