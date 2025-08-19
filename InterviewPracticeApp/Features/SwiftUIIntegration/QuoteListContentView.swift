//
//  QuoteListContentView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI

// MARK: - Content View
struct QuoteListContentView: View {
    let quotes: [Quote]
    let isLoading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(quotes) { quote in
                    QuoteCardView(quote: quote)
                        .padding(.horizontal)
                }
                
                if isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Cargando más citas...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            onRefresh()
        }
    }
}
