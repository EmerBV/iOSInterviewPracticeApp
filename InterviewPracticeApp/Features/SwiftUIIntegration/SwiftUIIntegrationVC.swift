//
//  SwiftUIIntegrationVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit
import SwiftUI

final class SwiftUIIntegrationVC: BaseViewController {
    
    // MARK: - Properties
    private var hostingController: UIHostingController<QuoteListContentWrapper>!
    private var quoteVM: QuoteVM!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Keep UIKit navigation visible
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupSwiftUIView() {
        // Create dependencies with fallback service
        let realService = QuoteService()
        let mockService = MockQuoteService()
        
        // Use a service that tries real API first, then falls back to mock
        let fallbackService = FallbackQuoteService(primaryService: realService, fallbackService: mockService)
        
        quoteVM = QuoteVM(quoteService: fallbackService)
        
        // Create SwiftUI view without NavigationView (since we use UIKit navigation)
        let swiftUIView = QuoteListContentWrapper(viewModel: quoteVM)
        
        // Create hosting controller
        hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    private func setupUI() {
        title = "SwiftUI + UIKit"
        
        // Add refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped)
        )
        
        // Configure hosting controller view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func refreshTapped() {
        quoteVM.refreshData()
    }
    
    // MARK: - Deinitializer
    deinit {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
    }
}
