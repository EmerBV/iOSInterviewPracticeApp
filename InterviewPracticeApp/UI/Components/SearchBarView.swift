//
//  SearchBarView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var selectedCategory: String
    let categories: [String]
    let onRandomQuote: () -> Void
    
    @State private var isSearchFocused = false
    @FocusState private var searchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar citas...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($searchFieldFocused)
                        .onTapGesture {
                            isSearchFocused = true
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchFieldFocused = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button(action: {
                    onRandomQuote()
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: categoryDisplayName(for: category),
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                // Add light haptic feedback for category selection
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusSearchBar)) { _ in
            searchFieldFocused = true
        }
    }
    
    // MARK: - Helper Methods
    private func categoryDisplayName(for category: String) -> String {
        switch category {
        case "all":
            return "Todas"
        default:
            return category.capitalized
        }
    }
}
