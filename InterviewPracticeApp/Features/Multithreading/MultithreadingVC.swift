//
//  MultithreadingVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class MultithreadingVC: BaseViewController {
    
    // MARK: - Properties
    private var operationQueue = OperationQueue()
    private var downloadTasks: [URLSessionDataTask] = []
    
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
    
    private lazy var gcdButton: UIButton = {
        let button = createButton(title: "GCD - Grand Central Dispatch", color: .systemBlue)
        button.addTarget(self, action: #selector(demonstrateGCD), for: .touchUpInside)
        return button
    }()
    
    private lazy var operationQueueButton: UIButton = {
        let button = createButton(title: "Operation Queue", color: .systemGreen)
        button.addTarget(self, action: #selector(demonstrateOperationQueue), for: .touchUpInside)
        return button
    }()
    
    private lazy var asyncAwaitButton: UIButton = {
        let button = createButton(title: "Async/Await", color: .systemPurple)
        button.addTarget(self, action: #selector(demonstrateAsyncAwait), for: .touchUpInside)
        return button
    }()
    
    private lazy var raceConditionButton: UIButton = {
        let button = createButton(title: "Race Condition Demo", color: .systemRed)
        button.addTarget(self, action: #selector(demonstrateRaceCondition), for: .touchUpInside)
        return button
    }()
    
    private lazy var threadSafeButton: UIButton = {
        let button = createButton(title: "Thread Safe Solution", color: .systemOrange)
        button.addTarget(self, action: #selector(demonstrateThreadSafety), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.text = "Resultados de concurrencia aparecerán aquí..."
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConcurrencyInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Cancel ongoing operations
        operationQueue.cancelAllOperations()
        downloadTasks.forEach { $0.cancel() }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Multithreading"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let buttons = [gcdButton, operationQueueButton, asyncAwaitButton, raceConditionButton, threadSafeButton]
        buttons.forEach { contentView.addSubview($0) }
        
        contentView.addSubview(progressView)
        contentView.addSubview(resultTextView)
        
        setupConstraints(buttons: buttons)
    }
    
    private func setupConstraints(buttons: [UIButton]) {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Button constraints
        for (index, button) in buttons.enumerated() {
            let topAnchor = index == 0 ? contentView.topAnchor : buttons[index - 1].bottomAnchor
            let constant: CGFloat = index == 0 ? 20 : 16
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor, constant: constant),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        // Progress and text view constraints
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: buttons.last!.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            resultTextView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            resultTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(equalToConstant: 300),
            resultTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupConcurrencyInfo() {
        appendToResults("=== MULTITHREADING & CONCURRENCY DEMO ===\n")
        appendToResults("Este demo muestra diferentes técnicas de concurrencia en iOS\n")
    }
    
    // MARK: - Actions
    @objc private func demonstrateGCD() {
        appendToResults("🔄 Demostrando Grand Central Dispatch (GCD)")
        
        // Simular trabajo pesado en background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.appendToResults("🏃‍♂️ Ejecutando en background thread...")
            
            // Simular procesamiento
            for i in 1...5 {
                Thread.sleep(forTimeInterval: 0.5)
                
                DispatchQueue.main.async {
                    self?.appendToResults("Progreso: \(i)/5")
                    self?.progressView.progress = Float(i) / 5.0
                }
            }
            
            DispatchQueue.main.async {
                self?.appendToResults("✅ GCD completado")
                self?.appendToResults("Regresado al main thread para UI\n")
                self?.progressView.progress = 0
            }
        }
    }
    
    @objc private func demonstrateOperationQueue() {
        appendToResults("⚙️ Demostrando Operation Queue")
        
        operationQueue.maxConcurrentOperationCount = 2
        
        // Crear múltiples operaciones
        for i in 1...4 {
            let operation = BlockOperation { [weak self] in
                self?.appendToResults("🔧 Operación \(i) iniciada")
                Thread.sleep(forTimeInterval: 1.0)
                
                DispatchQueue.main.async {
                    self?.appendToResults("✅ Operación \(i) completada")
                }
            }
            
            operationQueue.addOperation(operation)
        }
        
        // Operación final
        let finalOperation = BlockOperation { [weak self] in
            DispatchQueue.main.async {
                self?.appendToResults("🏁 Todas las operaciones completadas\n")
            }
        }
        
        operationQueue.addOperation(finalOperation)
    }
    
    @objc private func demonstrateAsyncAwait() {
        appendToResults("⚡ Demostrando Async/Await")
        
        Task { @MainActor in
            do {
                appendToResults("🚀 Iniciando tarea async...")
                
                let result = await performAsyncWork()
                appendToResults("📄 Resultado: \(result)")
                
                let data = try await fetchDataAsync()
                appendToResults("📊 Datos obtenidos: \(data.count) bytes")
                
                appendToResults("✅ Async/Await completado\n")
            } catch {
                appendToResults("❌ Error: \(error.localizedDescription)\n")
            }
        }
    }
    
    @objc private func demonstrateRaceCondition() {
        appendToResults("⚠️ Demostrando Race Condition")
        
        var unsafeCounter = 0
        let group = DispatchGroup()
        
        // Múltiples threads modificando la misma variable
        for i in 1...10 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 1...1000 {
                    unsafeCounter += 1 // Race condition!
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.appendToResults("🎯 Resultado esperado: 10,000")
            self?.appendToResults("🚨 Resultado actual: \(unsafeCounter)")
            self?.appendToResults("❌ Race condition detectada!")
            self?.appendToResults("Los resultados varían en cada ejecución\n")
        }
    }
    
    @objc private func demonstrateThreadSafety() {
        appendToResults("🛡️ Demostrando Thread Safety")
        
        let safeCounter = ThreadSafeCounter()
        let group = DispatchGroup()
        
        // Múltiples threads usando counter thread-safe
        for i in 1...10 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 1...1000 {
                    safeCounter.increment()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.appendToResults("🎯 Resultado esperado: 10,000")
            self?.appendToResults("✅ Resultado actual: \(safeCounter.value)")
            self?.appendToResults("🛡️ Thread safety garantizada!")
            self?.appendToResults("Usando serial queue para sincronización\n")
        }
    }
    
    // MARK: - Helper Methods
    private func performAsyncWork() async -> String {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                continuation.resume(returning: "Trabajo async completado")
            }
        }
    }
    
    private func fetchDataAsync() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                let data = "Datos simulados".data(using: .utf8) ?? Data()
                continuation.resume(returning: data)
            }
        }
    }
    
    private func appendToResults(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.resultTextView.text += text + "\n"
            
            let bottom = NSMakeRange(self?.resultTextView.text.count ?? 0 - 1, 1)
            self?.resultTextView.scrollRangeToVisible(bottom)
        }
    }
}
