//
//  BarChartView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class BarChartView: UIView {
    
    // MARK: - Properties
    private var data: [BarChartData] = []
    private var barViews: [UIView] = []
    private var maxValue: CGFloat = 100
    
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
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Recrear las barras cuando cambia el layout
        if !data.isEmpty && bounds.width > 0 && bounds.height > 0 {
            createBars()
        }
    }
    
    func setData(_ newData: [BarChartData]) {
        self.data = newData
        self.maxValue = newData.map { $0.value }.max() ?? 100
        
        // Remove old views
        barViews.forEach { $0.removeFromSuperview() }
        barViews.removeAll()
        
        // Solo crear barras si ya tenemos el layout
        if bounds.width > 0 && bounds.height > 0 {
            createBars()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animateBars()
            }
        }
    }
    
    private func createBars() {
        guard !data.isEmpty, bounds.width > 0, bounds.height > 0 else { return }
        
        // Limpiar barras anteriores
        barViews.forEach { $0.removeFromSuperview() }
        barViews.removeAll()
        
        let padding: CGFloat = 20
        let labelHeight: CGFloat = 40
        let availableWidth = bounds.width - (padding * 2)
        let availableHeight = bounds.height - (padding * 2) - labelHeight
        let barSpacing: CGFloat = 8
        let totalSpacing = CGFloat(data.count - 1) * barSpacing
        let barWidth = (availableWidth - totalSpacing) / CGFloat(data.count)
        
        for (index, item) in data.enumerated() {
            // Container para la barra y etiquetas
            let containerView = UIView()
            containerView.backgroundColor = .clear
            addSubview(containerView)
            
            // Calcular posición
            let xPosition = padding + CGFloat(index) * (barWidth + barSpacing)
            let barHeight = (item.value / maxValue) * availableHeight
            let yPosition = padding + (availableHeight - barHeight)
            
            containerView.frame = CGRect(
                x: xPosition,
                y: padding,
                width: barWidth,
                height: availableHeight + labelHeight
            )
            
            // Crear la barra
            let barView = UIView()
            barView.backgroundColor = item.color
            barView.layer.cornerRadius = min(4, barWidth / 8)
            containerView.addSubview(barView)
            
            barView.frame = CGRect(
                x: 0,
                y: availableHeight - barHeight,
                width: barWidth,
                height: barHeight
            )
            
            // Etiqueta de valor
            let valueLabel = UILabel()
            valueLabel.text = "\(Int(item.value))"
            valueLabel.textAlignment = .center
            valueLabel.font = .boldSystemFont(ofSize: min(12, barWidth / 4))
            valueLabel.textColor = .label
            valueLabel.adjustsFontSizeToFitWidth = true
            valueLabel.minimumScaleFactor = 0.8
            containerView.addSubview(valueLabel)
            
            valueLabel.frame = CGRect(
                x: 0,
                y: max(0, availableHeight - barHeight - 20),
                width: barWidth,
                height: 16
            )
            
            // Etiqueta del título
            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.textAlignment = .center
            titleLabel.font = .systemFont(ofSize: min(12, barWidth / 4))
            titleLabel.textColor = .secondaryLabel
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.7
            containerView.addSubview(titleLabel)
            
            titleLabel.frame = CGRect(
                x: 0,
                y: availableHeight + 5,
                width: barWidth,
                height: 16
            )
            
            barViews.append(barView)
        }
    }
    
    private func animateBars() {
        for (index, barView) in barViews.enumerated() {
            let originalFrame = barView.frame
            
            // Empezar sin altura
            barView.frame = CGRect(
                x: originalFrame.origin.x,
                y: originalFrame.origin.y + originalFrame.height,
                width: originalFrame.width,
                height: 0
            )
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut],
                animations: {
                    barView.frame = originalFrame
                }
            )
        }
    }
}
