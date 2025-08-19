//
//  QuoteListContentWrapper.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI

// MARK: - SwiftUI Content Wrapper
struct QuoteListContentWrapper: View {
    @StateObject private var viewModel: QuoteVM
    @State private var showingAlert = false
    @State private var searchFocused = false
    let onBack: (() -> Void)?
    
    init(viewModel: QuoteVM, onBack: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search and Filter Section
                SearchBarView(
                    searchText: $viewModel.searchText,
                    selectedCategory: $viewModel.selectedCategory,
                    categories: viewModel.availableCategories,
                    onRandomQuote: {
                        viewModel.fetchRandomQuote()
                    }
                )
                .padding()
                .background(Color(.systemBackground))
                
                // Content Section
                if viewModel.isLoading && viewModel.quotes.isEmpty {
                    LoadingStateView()
                } else if viewModel.filteredQuotes.isEmpty {
                    EmptyStateView(
                        title: viewModel.searchText.isEmpty ? "No hay citas" : "Sin resultados",
                        message: viewModel.searchText.isEmpty ?
                        "Toca el botón de recargar para obtener citas" :
                            "Intenta con términos de búsqueda diferentes",
                        action: {
                            viewModel.refreshData()
                        }
                    )
                } else {
                    QuoteListContentView(
                        quotes: viewModel.filteredQuotes,
                        isLoading: viewModel.isLoading,
                        onRefresh: {
                            viewModel.refreshData()
                        }
                    )
                }
            }
        }
        .onAppear {
            if viewModel.quotes.isEmpty {
                viewModel.fetchQuotes()
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
            Button("Reintentar") {
                viewModel.refreshData()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Ha ocurrido un error")
        }
        .onChange(of: viewModel.errorMessage) { error in
            showingAlert = error != nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshQuotes)) { _ in
            viewModel.refreshData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSearchBar)) { _ in
            searchFocused = true
        }
    }
}

// MARK: - Notification Extensions (Enhanced)
extension Notification.Name {
    static let refreshQuotes = Notification.Name("refreshQuotes")
    static let focusSearchBar = Notification.Name("focusSearchBar")
    static let randomQuoteRequested = Notification.Name("randomQuoteRequested")
}
