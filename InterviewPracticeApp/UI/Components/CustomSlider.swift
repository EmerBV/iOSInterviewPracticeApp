//
//  CustomSlider.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class CustomSlider: UIControl {
    
    // MARK: - Properties
    var minimumValue: Float = 0 {
        didSet { updateThumbPosition() }
    }
    
    var maximumValue: Float = 1 {
        didSet { updateThumbPosition() }
    }
    
    var value: Float = 0 {
        didSet {
            value = max(minimumValue, min(maximumValue, value))
            updateThumbPosition()
        }
    }
    
    private let trackLayer = CALayer()
    private let progressLayer = CALayer()
    private let thumbView = UIView()
    
    private var thumbWidthConstraint: NSLayoutConstraint!
    private var thumbHeightConstraint: NSLayoutConstraint!
    private var thumbCenterXConstraint: NSLayoutConstraint!
    
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
        updateThumbPosition()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Setup track layer
        trackLayer.backgroundColor = UIColor.systemGray5.cgColor
        trackLayer.cornerRadius = 2
        layer.addSublayer(trackLayer)
        
        // Setup progress layer
        progressLayer.backgroundColor = UIColor.systemBlue.cgColor
        progressLayer.cornerRadius = 2
        layer.addSublayer(progressLayer)
        
        // Setup thumb
        thumbView.backgroundColor = .systemBlue
        thumbView.layer.cornerRadius = 12
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbView.layer.shadowRadius = 4
        thumbView.layer.shadowOpacity = 0.3
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(thumbView)
        
        thumbWidthConstraint = thumbView.widthAnchor.constraint(equalToConstant: 24)
        thumbHeightConstraint = thumbView.heightAnchor.constraint(equalToConstant: 24)
        thumbCenterXConstraint = thumbView.centerXAnchor.constraint(equalTo: leadingAnchor)
        
        NSLayoutConstraint.activate([
            thumbView.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbWidthConstraint,
            thumbHeightConstraint,
            thumbCenterXConstraint
        ])
        
        // Add gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func updateLayers() {
        let trackHeight: CGFloat = 4
        let trackY = (bounds.height - trackHeight) / 2
        
        trackLayer.frame = CGRect(x: 12, y: trackY, width: bounds.width - 24, height: trackHeight)
        
        let progressWidth = CGFloat((value - minimumValue) / (maximumValue - minimumValue)) * trackLayer.bounds.width
        progressLayer.frame = CGRect(x: trackLayer.frame.minX, y: trackY, width: progressWidth, height: trackHeight)
    }
    
    private func updateThumbPosition() {
        let thumbPosition = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
        let thumbX = 12 + thumbPosition * (bounds.width - 24)
        thumbCenterXConstraint.constant = thumbX
    }
    
    // MARK: - Touch Handling
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        updateValue(for: location)
        
        if gesture.state == .began {
            animateThumb(scale: 1.2)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            animateThumb(scale: 1.0)
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        updateValue(for: location)
        
        animateThumb(scale: 1.2) {
            self.animateThumb(scale: 1.0)
        }
    }
    
    private func updateValue(for location: CGPoint) {
        let trackWidth = bounds.width - 24
        let thumbPosition = max(0, min(trackWidth, location.x - 12))
        let percentage = thumbPosition / trackWidth
        
        let newValue = minimumValue + Float(percentage) * (maximumValue - minimumValue)
        value = newValue
        
        sendActions(for: .valueChanged)
    }
    
    private func animateThumb(scale: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.thumbView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            completion?()
        })
    }
}
