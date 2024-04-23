//
//  StarryNightView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-24.
//

import Foundation
import SwiftUI


class StarryNightView: UIView {
    private var stars: [CAShapeLayer] = []
    private let colors = [UIColor.white.cgColor, UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawStars(numberOfStars: 100)
    }
    
    private func drawStars(numberOfStars: Int) {
        for _ in 0..<numberOfStars {
            let starLayer = CAShapeLayer()
            let x = CGFloat.random(in: 0...bounds.width)
            let y = CGFloat.random(in: 0...bounds.height)
            let diameter: CGFloat = Double.random(in: 3...5.0)
            starLayer.path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: diameter, height: diameter)).cgPath
            starLayer.fillColor = colors.randomElement()
            layer.addSublayer(starLayer)
            stars.append(starLayer)
            animateTwinkle(starLayer: starLayer)
        }
    }
    
    private func animateTwinkle(starLayer: CAShapeLayer) {
        CATransaction.begin()
        
        // Completion block for the twinkle animation
        CATransaction.setCompletionBlock {
            // This block is called after the twinkle animation completes
            
            // Move to a new location after twinkling
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            starLayer.position = CGPoint(x: CGFloat.random(in: 0...self.bounds.width),
                                         y: CGFloat.random(in: 0...self.bounds.height))
            CATransaction.commit()
            
            self.animateTwinkle(starLayer: starLayer)
        }
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        fadeAnimation.duration = Double.random(in: 1...5.0)
        fadeAnimation.autoreverses = true
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.fillMode = .forwards
        fadeAnimation.repeatCount = 5
        
        // Add the twinkle animation to the star layer
        starLayer.add(fadeAnimation, forKey: "twinkle")
        
        CATransaction.commit()
    }
}

// Step 3: SwiftUI Integration
struct StarryNightRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> StarryNightView {
        return StarryNightView()
    }
    
    func updateUIView(_ uiView: StarryNightView, context: Context) {
        // Update the view if needed
    }
}

struct StarryNightViewWrapper: View {
    var body: some View {
        StarryNightRepresentable()
            .edgesIgnoringSafeArea(.all)
            .background(.clear)
    }
}

struct StarryNightViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        StarryNightViewWrapper()
    }
}

