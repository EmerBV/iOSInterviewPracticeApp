//
//  QuoteListView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI
import Combine

struct QuoteListView: View {
    @StateObject private var viewModel: QuoteVM
    @State private var showingAlert = false
    
    init(viewModel: QuoteVM = QuoteVM()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Citas Inspiradoras")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.isLoading)
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
        } message: {
            Text(viewModel.errorMessage ?? "Ha ocurrido un error")
        }
        .onChange(of: viewModel.errorMessage) { error in
            showingAlert = error != nil
        }
    }
}

// MARK: - Previews
struct QuoteListView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteListView()
    }
}
