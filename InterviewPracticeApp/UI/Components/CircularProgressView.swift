//
//  CircularProgressView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class CircularProgressView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var backgroundLayer = CAShapeLayer()
    private var progressLabel = UILabel()
    
    private var currentProgress: CGFloat = 0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        
        // Setup background layer
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.lineWidth = 8
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        // Setup progress layer
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        // Setup label
        progressLabel.textAlignment = .center
        progressLabel.font = .boldSystemFont(ofSize: 24)
        progressLabel.textColor = .label
        progressLabel.text = "0%"
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - progressLayer.lineWidth / 2
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        
        backgroundLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        let clampedProgress = max(0, min(1, progress))
        currentProgress = clampedProgress
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedProgress
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.strokeEnd = clampedProgress
        
        // Update label
        let percentage = Int(clampedProgress * 100)
        progressLabel.text = "\(percentage)%"
    }
}
