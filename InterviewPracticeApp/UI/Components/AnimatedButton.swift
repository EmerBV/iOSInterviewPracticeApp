//
//  AnimatedButton.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class AnimatedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .systemBlue
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        layer.cornerRadius = 8
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
    }
    
    func animate() {
        // Scale animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        // Pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.6
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 2
        layer.add(pulseAnimation, forKey: "pulse")
        
        // Color animation
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = .systemGreen
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = .systemBlue
            }
        }
    }
}
