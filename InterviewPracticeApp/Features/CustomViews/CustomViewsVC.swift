//
//  CustomViewsVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class CustomViewsVC: BaseViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var circularProgressView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customSlider: CustomSlider = {
        let slider = CustomSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var animatedButton: AnimatedButton = {
        let button = AnimatedButton()
        button.setTitle("Animar", for: .normal)
        button.addTarget(self, action: #selector(animateButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var chartView: BarChartView = {
        let view = BarChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.colors = [.systemBlue, .systemPurple]
        view.startPoint = CGPoint(x: 0, y: 0)
        view.endPoint = CGPoint(x: 1, y: 1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSampleData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimations()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Custom Views"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(createSectionLabel(text: "Circular Progress"))
        contentView.addSubview(circularProgressView)
        
        contentView.addSubview(createSectionLabel(text: "Custom Slider"))
        contentView.addSubview(customSlider)
        
        contentView.addSubview(createSectionLabel(text: "Animated Button"))
        contentView.addSubview(animatedButton)
        
        contentView.addSubview(createSectionLabel(text: "Bar Chart"))
        contentView.addSubview(chartView)
        
        contentView.addSubview(createSectionLabel(text: "Gradient View"))
        contentView.addSubview(gradientView)
        
        contentView.addSubview(createSectionLabel(text: "Loading Animation"))
        contentView.addSubview(loadingView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let progressLabel = contentView.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "Circular Progress" }!
        let sliderLabel = contentView.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "Custom Slider" }!
        let buttonLabel = contentView.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "Animated Button" }!
        let chartLabel = contentView.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "Bar Chart" }!
        let gradientLabel = contentView.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "Gradient View" }!
        let loadingLabel = contentView.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "Loading Animation" }!
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Progress section
            progressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            circularProgressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            circularProgressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circularProgressView.widthAnchor.constraint(equalToConstant: 120),
            circularProgressView.heightAnchor.constraint(equalToConstant: 120),
            
            // Slider section
            sliderLabel.topAnchor.constraint(equalTo: circularProgressView.bottomAnchor, constant: 30),
            sliderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            customSlider.topAnchor.constraint(equalTo: sliderLabel.bottomAnchor, constant: 10),
            customSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            customSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            customSlider.heightAnchor.constraint(equalToConstant: 40),
            
            // Button section
            buttonLabel.topAnchor.constraint(equalTo: customSlider.bottomAnchor, constant: 30),
            buttonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            animatedButton.topAnchor.constraint(equalTo: buttonLabel.bottomAnchor, constant: 10),
            animatedButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            animatedButton.widthAnchor.constraint(equalToConstant: 120),
            animatedButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Chart section
            chartLabel.topAnchor.constraint(equalTo: animatedButton.bottomAnchor, constant: 30),
            chartLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            chartView.topAnchor.constraint(equalTo: chartLabel.bottomAnchor, constant: 10),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chartView.heightAnchor.constraint(equalToConstant: 200),
            
            // Gradient section
            gradientLabel.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 30),
            gradientLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            gradientView.topAnchor.constraint(equalTo: gradientLabel.bottomAnchor, constant: 10),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            gradientView.heightAnchor.constraint(equalToConstant: 100),
            
            // Loading section
            loadingLabel.topAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: 30),
            loadingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            loadingView.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 10),
            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 60),
            loadingView.heightAnchor.constraint(equalToConstant: 60),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func createSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupSampleData() {
        // Setup chart data
        let data = [
            BarChartData(title: "Ene", value: 45, color: .systemBlue),
            BarChartData(title: "Feb", value: 67, color: .systemGreen),
            BarChartData(title: "Mar", value: 23, color: .systemOrange),
            BarChartData(title: "Abr", value: 89, color: .systemRed),
            BarChartData(title: "May", value: 34, color: .systemPurple)
        ]
        chartView.setData(data)
    }
    
    private func startAnimations() {
        // Start circular progress animation
        circularProgressView.setProgress(0.75, animated: true)
        
        // Start loading animation
        loadingView.startAnimating()
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged(_ slider: CustomSlider) {
        let progress = slider.value / slider.maximumValue
        circularProgressView.setProgress(CGFloat(progress), animated: true)
    }
    
    @objc private func animateButtonTapped() {
        animatedButton.animate()
        
        // Restart loading animation
        loadingView.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadingView.startAnimating()
        }
    }
}
