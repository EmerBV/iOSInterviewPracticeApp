//
//  GradientView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class GradientView: UIView {
    
    // MARK: - Properties
    var colors: [UIColor] = [.systemBlue, .systemPurple] {
        didSet { updateGradient() }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { updateGradient() }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet { updateGradient() }
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    // MARK: - Initialization
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
    
    private func setupGradient() {
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
}
