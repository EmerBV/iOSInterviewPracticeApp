//
//  MemoryManagementVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit

final class MemoryManagementVC: BaseViewController {
    
    // MARK: - Properties
    private var strongReferences: [AnyObject] = []
    private weak var weakReference: UIView?
    private var timer: Timer?
    
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
    
    private lazy var strongReferenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Crear Strong Reference", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(createStrongReference), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var weakReferenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Crear Weak Reference", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(createWeakReference), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var retainCycleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Demostrar Retain Cycle", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(demonstrateRetainCycle), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cleanupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Limpiar Referencias", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cleanup), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.text = "Resultados aparecerán aquí..."
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMemoryExamples()
    }
    
    deinit {
        timer?.invalidate()
        print("MemoryManagementViewController deinit - memoria liberada correctamente")
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Memory Management"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(strongReferenceButton)
        contentView.addSubview(weakReferenceButton)
        contentView.addSubview(retainCycleButton)
        contentView.addSubview(cleanupButton)
        contentView.addSubview(resultTextView)
        
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
            
            strongReferenceButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            strongReferenceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            strongReferenceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            strongReferenceButton.heightAnchor.constraint(equalToConstant: 44),
            
            weakReferenceButton.topAnchor.constraint(equalTo: strongReferenceButton.bottomAnchor, constant: 16),
            weakReferenceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weakReferenceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weakReferenceButton.heightAnchor.constraint(equalToConstant: 44),
            
            retainCycleButton.topAnchor.constraint(equalTo: weakReferenceButton.bottomAnchor, constant: 16),
            retainCycleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            retainCycleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            retainCycleButton.heightAnchor.constraint(equalToConstant: 44),
            
            cleanupButton.topAnchor.constraint(equalTo: retainCycleButton.bottomAnchor, constant: 16),
            cleanupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cleanupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cleanupButton.heightAnchor.constraint(equalToConstant: 44),
            
            resultTextView.topAnchor.constraint(equalTo: cleanupButton.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(equalToConstant: 300),
            resultTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupMemoryExamples() {
        appendToResults("=== MEMORY MANAGEMENT DEMO ===\n")
        appendToResults("Este demo muestra conceptos importantes de ARC (Automatic Reference Counting)\n\n")
    }
    
    // MARK: - Actions
    @objc private func createStrongReference() {
        let newView = UIView()
        newView.backgroundColor = .systemBlue
        strongReferences.append(newView)
        
        appendToResults("✅ Strong Reference creada")
        appendToResults("Total strong references: \(strongReferences.count)")
        appendToResults("El objeto se mantiene en memoria porque hay una referencia fuerte\n")
    }
    
    @objc private func createWeakReference() {
        let newView = UIView()
        newView.backgroundColor = .systemGreen
        weakReference = newView
        
        appendToResults("⚠️ Weak Reference creada")
        appendToResults("Weak reference exists: \(weakReference != nil)")
        
        // El objeto se libera inmediatamente porque no hay referencias fuertes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.appendToResults("Weak reference después de un momento: \(self?.weakReference != nil)")
            self?.appendToResults("El objeto se liberó porque no había referencias fuertes\n")
        }
    }
    
    @objc private func demonstrateRetainCycle() {
        let parent = ParentClass()
        let child = ChildClass()
        
        // Crear retain cycle
        parent.child = child
        child.parent = parent // Strong reference - esto crea un retain cycle
        
        appendToResults("🔄 Retain Cycle creado")
        appendToResults("Parent tiene referencia fuerte a Child")
        appendToResults("Child tiene referencia fuerte a Parent")
        appendToResults("Esto causa un retain cycle - ningún objeto se liberará")
        appendToResults("Solución: usar weak o unowned references\n")
        
        // Demostrar la solución
        demonstrateRetainCycleSolution()
    }
    
    private func demonstrateRetainCycleSolution() {
        let parent = ParentClassFixed()
        let child = ChildClassFixed()
        
        parent.child = child
        child.parent = parent // Weak reference - NO crea retain cycle
        
        appendToResults("✅ Solución al Retain Cycle")
        appendToResults("Child ahora usa weak reference a Parent")
        appendToResults("Los objetos se liberarán correctamente\n")
    }
    
    @objc private func cleanup() {
        strongReferences.removeAll()
        weakReference = nil
        
        appendToResults("🧹 Cleanup realizado")
        appendToResults("Todas las referencias fuertes eliminadas")
        appendToResults("Total strong references: \(strongReferences.count)\n")
    }
    
    private func appendToResults(_ text: String) {
        resultTextView.text += text + "\n"
        
        // Scroll to bottom
        let bottom = NSMakeRange(resultTextView.text.count - 1, 1)
        resultTextView.scrollRangeToVisible(bottom)
    }
}
