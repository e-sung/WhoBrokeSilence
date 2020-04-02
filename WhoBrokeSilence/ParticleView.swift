//
//  ParticleView.swift
//  WhoBrokeSilence
//
//  Created by 류성두 on 2020/03/31.
//  Copyright © 2020 류성두. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ParticleView: UIView {

    lazy var animator:UIDynamicAnimator = {
        UIDynamicAnimator(referenceView: self)
    }()
    var collision = UICollisionBehavior()
    var elasticity = UIDynamicItemBehavior()
    var positivecharge = UIDynamicItemBehavior()
    
    var particleGenerater: (() -> UIView)?
    var lastPopedTime = Date()
    var cancelBag:[Cancellable] = []
    let centerView = UIView()
    
    var viewModel = MainViewModel.shared
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if particleGenerater == nil {
            particleGenerater = {
                let particle = UIView(frame: CGRect(origin: self.center, size: CGSize(width: 40, height: 40)))
                particle.backgroundColor = .red
                particle.layer.cornerRadius = particle.frame.width / 2
                return particle
            }
        }

        collision.translatesReferenceBoundsIntoBoundary = true
        collision.setTranslatesReferenceBoundsIntoBoundary(with: .zero)
        collision.collisionMode = .everything
        elasticity.elasticity = 0.5
        
        positivecharge.charge = 1

        addSubview(centerView)

        
        animator.addBehavior(collision)
        animator.addBehavior(elasticity)
        
        let bindBPMtoParticle = viewModel.$burstPerMinute.sink { [unowned self] output in
            if self.viewModel.burstPerMinute > self.viewModel.threshHoldBPM {
                self.reset()
            }
            else {
                self.popParticle()
            }
        }

        cancelBag.append(bindBPMtoParticle)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        subviews.forEach {
            fadeOut(particle: $0)
        }
    }
    
    func popParticle() {
        guard let particle = particleGenerater?() else { return }
    
        particle.backgroundColor = .red
        particle.layer.cornerRadius = particle.frame.width / 2
        addSubview(particle)
        collision.addItem(particle)
        elasticity.addItem(particle)
        positivecharge.addItem(particle)

        let push = UIPushBehavior(items: [particle], mode: .instantaneous)
        push.magnitude = 1.5
        push.angle = CGFloat.random(in: 0...2*CGFloat.pi)
        
        animator.addBehavior(push)
        lastPopedTime = Date()
    }
    
    func fadeOut(particle: UIView) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 2
        scale.duration = 0.8
        
        let alpha = CABasicAnimation(keyPath: "opacity")
        alpha.fromValue = 1
        alpha.toValue = 0
        alpha.duration = 0.8

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            particle.removeFromSuperview()
        }
        particle.layer.add(alpha, forKey: nil)
        particle.layer.add(scale,forKey: nil)
        CATransaction.commit()
    }

}
