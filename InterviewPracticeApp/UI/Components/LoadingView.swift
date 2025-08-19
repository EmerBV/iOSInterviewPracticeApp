//
//  LoadingView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class LoadingView: UIView {
    
    // MARK: - Properties
    private var isAnimating = false
    private var dots: [UIView] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Create dots
        for i in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .systemBlue
            dot.layer.cornerRadius = 6
            dot.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dot)
            dots.append(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 12),
                dot.heightAnchor.constraint(equalToConstant: 12),
                dot.centerYAnchor.constraint(equalTo: centerYAnchor),
                dot.centerXAnchor.constraint(equalTo: centerXAnchor, constant: CGFloat(i - 1) * 20)
            ])
        }
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        
        for (index, dot) in dots.enumerated() {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 1.5
            animation.duration = 0.6
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            dot.layer.add(animation, forKey: "scale")
            
            let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
            colorAnimation.fromValue = UIColor.systemBlue.cgColor
            colorAnimation.toValue = UIColor.systemPurple.cgColor
            colorAnimation.duration = 0.6
            colorAnimation.repeatCount = .infinity
            colorAnimation.autoreverses = true
            colorAnimation.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            dot.layer.add(colorAnimation, forKey: "color")
        }
    }
    
    func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        
        dots.forEach { dot in
            dot.layer.removeAllAnimations()
        }
    }
}
