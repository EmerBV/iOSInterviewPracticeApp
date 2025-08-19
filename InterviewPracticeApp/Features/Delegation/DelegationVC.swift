//
//  DelegationVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class DelegationVC: BaseViewController {
    
    // MARK: - Properties
    private var customTextField: CustomTextField!
    private var dataProcessor: DataProcessor!
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delegation Pattern Demo"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textFieldContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Custom TextField con Delegate:"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var processButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Procesar Datos", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(processData), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.text = "Eventos del delegate aparecerán aquí..."
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupDelegationInfo()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Delegation Pattern"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textFieldContainerView)
        
        textFieldContainerView.addSubview(textFieldLabel)
        
        // Create custom text field
        customTextField = CustomTextField()
        customTextField.placeholder = "Escribe algo aquí..."
        customTextField.borderStyle = .roundedRect
        customTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainerView.addSubview(customTextField)
        
        contentView.addSubview(processButton)
        contentView.addSubview(resultTextView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            textFieldContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            textFieldContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textFieldContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            textFieldLabel.topAnchor.constraint(equalTo: textFieldContainerView.topAnchor, constant: 16),
            textFieldLabel.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 16),
            textFieldLabel.trailingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: -16),
            
            customTextField.topAnchor.constraint(equalTo: textFieldLabel.bottomAnchor, constant: 12),
            customTextField.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: -16),
            customTextField.heightAnchor.constraint(equalToConstant: 44),
            customTextField.bottomAnchor.constraint(equalTo: textFieldContainerView.bottomAnchor, constant: -16),
            
            processButton.topAnchor.constraint(equalTo: textFieldContainerView.bottomAnchor, constant: 20),
            processButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            processButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            processButton.heightAnchor.constraint(equalToConstant: 44),
            
            resultTextView.topAnchor.constraint(equalTo: processButton.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(equalToConstant: 250),
            resultTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupDelegates() {
        customTextField.customDelegate = self
        
        dataProcessor = DataProcessor()
        dataProcessor.delegate = self
    }
    
    private func setupDelegationInfo() {
        appendToResults("=== DELEGATION PATTERN DEMO ===\n")
        appendToResults("El patrón Delegate permite comunicación entre objetos")
        appendToResults("sin crear dependencias fuertes.\n")
        appendToResults("Prueba escribir en el TextField o procesar datos.\n")
    }
    
    // MARK: - Actions
    @objc private func processData() {
        let inputText = customTextField.text ?? "Datos por defecto"
        dataProcessor.processData(inputText)
    }
    
    private func appendToResults(_ text: String) {
        resultTextView.text += text + "\n"
        
        let bottom = NSMakeRange(resultTextView.text.count - 1, 1)
        resultTextView.scrollRangeToVisible(bottom)
    }
}

// MARK: - Delegation View Controller Extensions
extension DelegationVC: CustomTextFieldDelegate {
    
    func textFieldDidStartEditing(_ textField: CustomTextField) {
        appendToResults("📝 TextField comenzó edición")
    }
    
    func textFieldDidChange(_ textField: CustomTextField, text: String) {
        appendToResults("✏️ TextField cambió: '\(text)'")
    }
    
    func textFieldDidEndEditing(_ textField: CustomTextField) {
        appendToResults("📝 TextField terminó edición")
    }
    
    func textFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        textField.resignFirstResponder()
        appendToResults("⏎ TextField return presionado")
        return true
    }
}

extension DelegationVC: DataProcessorDelegate {
    
    func dataProcessor(_ processor: DataProcessor, didStartProcessing data: String) {
        appendToResults("🔄 Iniciando procesamiento de: '\(data)'")
    }
    
    func dataProcessor(_ processor: DataProcessor, didFinishProcessing result: String) {
        appendToResults("✅ Procesamiento completado: \(result)")
    }
    
    func dataProcessor(_ processor: DataProcessor, didFailWithError error: Error) {
        appendToResults("❌ Error en procesamiento: \(error.localizedDescription)")
    }
}
