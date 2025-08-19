//
//  SwiftUIIntegrationWithNavVC.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import UIKit
import SwiftUI
import Combine

// MARK: - Alternative Implementation with Custom Navigation
final class SwiftUIIntegrationWithNavVC: BaseViewController {
    
    // MARK: - Properties
    private var hostingController: UIHostingController<AnyView>!
    private var quoteVM: QuoteVM!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIViewWithCustomNav()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    private func setupSwiftUIViewWithCustomNav() {
        // Create dependencies with fallback service
        let realService = QuoteService()
        let mockService = MockQuoteService()
        let fallbackService = FallbackQuoteService(primaryService: realService, fallbackService: mockService)
        
        quoteVM = QuoteVM(quoteService: fallbackService)
        
        // Create a custom SwiftUI view that integrates with UIKit navigation
        let swiftUIContent = QuoteListContentWrapper(viewModel: quoteVM) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        // Create hosting controller with type erasure
        hostingController = UIHostingController(rootView: AnyView(swiftUIContent))
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    private func setupUI() {
        title = "SwiftUI + Custom Nav"
        
        // Configure hosting controller view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add toolbar buttons
        setupNavigationButtons()
    }
    
    private func setupNavigationButtons() {
        // Refresh button
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped)
        )
        
        // Random quote button
        let randomButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(randomQuoteTapped)
        )
        
        navigationItem.rightBarButtonItems = [refreshButton, randomButton]
        
        // Search button (optional)
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchTapped)
        )
        navigationItem.leftBarButtonItem = searchButton
    }
    
    private func setupBindings() {
        // Listen to ViewModel state changes for UI updates
        quoteVM.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        quoteVM.$quotes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quotes in
                self?.updateQuoteCount(quotes.count)
            }
            .store(in: &cancellables)
        
        // Listen for refresh notifications
        NotificationCenter.default.publisher(for: .refreshQuotes)
            .sink { [weak self] _ in
                self?.refreshTapped()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        quoteVM.refreshData()
        
        // Visual feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func randomQuoteTapped() {
        quoteVM.fetchRandomQuote()
        
        // Visual feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func searchTapped() {
        // Focus on search bar in SwiftUI
        NotificationCenter.default.post(name: .focusSearchBar, object: nil)
    }
    
    // MARK: - UI Updates
    private func updateLoadingState(_ isLoading: Bool) {
        navigationItem.rightBarButtonItems?.forEach { button in
            button.isEnabled = !isLoading
        }
        
        if isLoading {
            // Add loading indicator to navigation bar
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            let loadingItem = UIBarButtonItem(customView: activityIndicator)
            navigationItem.rightBarButtonItems?.append(loadingItem)
        } else {
            // Remove loading indicator
            navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.filter { item in
                !(item.customView is UIActivityIndicatorView)
            }
        }
    }
    
    private func updateQuoteCount(_ count: Int) {
        // Update title with quote count
        title = count > 0 ? "SwiftUI + Nav (\(count))" : "SwiftUI + Custom Nav"
    }
    
    // MARK: - Deinitializer
    deinit {
        cancellables.removeAll()
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
    }
}
