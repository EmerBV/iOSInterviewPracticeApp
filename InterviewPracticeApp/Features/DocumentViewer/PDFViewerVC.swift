//
//  PDFViewerVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit
import PDFKit

final class PDFViewerVC: BaseViewController {
    
    // MARK: - Properties
    private let document: InterviewDocument
    private var pdfDocument: PDFDocument?
    
    // MARK: - UI Components
    private lazy var pdfView: PDFView = {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        return pdfView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "No se pudo cargar el documento"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    init(document: InterviewDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPDF()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = document.title
        
        // Add share button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped)
        )
        
        view.addSubview(pdfView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func loadPDF() {
        loadingIndicator.startAnimating()
        
        // Try to load from bundle first
        if let bundlePath = document.bundlePath,
           let pdfDocument = PDFDocument(url: URL(fileURLWithPath: bundlePath)) {
            self.pdfDocument = pdfDocument
            pdfView.document = pdfDocument
            loadingIndicator.stopAnimating()
            return
        }
        
        // If not found in bundle, create a sample PDF
        createSamplePDF()
    }
    
    private func createSamplePDF() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let pdfDocument = PDFContentGenerator.generatePDF(for: self.document)
            
            DispatchQueue.main.async {
                if let pdfDocument = pdfDocument {
                    self.pdfDocument = pdfDocument
                    self.pdfView.document = pdfDocument
                    self.loadingIndicator.stopAnimating()
                } else {
                    self.showError()
                }
            }
        }
    }
    
    private func showError() {
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = false
        pdfView.isHidden = true
    }
    
    // MARK: - Actions
    @objc private func shareTapped() {
        guard let pdfDocument = pdfDocument,
              let data = pdfDocument.dataRepresentation() else {
            showAlert(title: "Error", message: "No se pudo compartir el documento")
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(document.title).pdf")
        
        do {
            try data.write(to: tempURL)
            
            let activityViewController = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            // For iPad
            if let popover = activityViewController.popoverPresentationController {
                popover.barButtonItem = navigationItem.rightBarButtonItem
            }
            
            present(activityViewController, animated: true)
        } catch {
            showAlert(title: "Error", message: "No se pudo preparar el documento para compartir")
        }
    }
}

// MARK: - PDFView Delegate (Optional)
extension PDFViewerVC: PDFViewDelegate {
    
    func pdfViewWillClickOnLink(_ sender: PDFView, with url: URL) {
        // Handle link clicks if needed
        UIApplication.shared.open(url)
    }
}
