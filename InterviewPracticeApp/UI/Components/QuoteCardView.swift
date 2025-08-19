//
//  QuoteCardView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI

struct QuoteCardView: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quote.quote)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("— \(quote.author)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    // Fixed: Proper optional handling
                    Text((quote.category ?? "general").capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor.opacity(0.1))
                        .foregroundColor(categoryColor)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: {
                    shareQuote()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    private var categoryColor: Color {
        // Different colors for different categories
        switch quote.category?.lowercased() {
        case "motivational":
            return .blue
        case "inspirational":
            return .green
        case "wisdom":
            return .purple
        case "humor", "funny":
            return .orange
        case "love":
            return .pink
        case "life":
            return .indigo
        case "success":
            return .mint
        default:
            return .gray
        }
    }
    
    private func shareQuote() {
        let shareText = "\"\(quote.quote)\" - \(quote.author)"
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(
                x: rootViewController.view.bounds.midX,
                y: rootViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityViewController, animated: true)
    }
}

// MARK: - Enhanced Quote Card with Animation
struct AnimatedQuoteCardView: View {
    let quote: Quote
    @State private var isVisible = false
    
    var body: some View {
        QuoteCardView(quote: quote)
            .scaleEffect(isVisible ? 1.0 : 0.95)
            .opacity(isVisible ? 1.0 : 0.8)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .onAppear {
                withAnimation {
                    isVisible = true
                }
            }
    }
}

// MARK: - Preview
/*
 struct QuoteCardView_Previews: PreviewProvider {
 static var previews: some View {
 VStack(spacing: 16) {
 // Preview with category
 QuoteCardView(quote: Quote(
 id: 1,
 quote: "The only way to do great work is to love what you do.",
 author: "Steve Jobs",
 category: "motivational"
 ))
 
 // Preview without category (nil case)
 QuoteCardView(quote: Quote(
 id: 2,
 quote: "Life is what happens when you're busy making other plans.",
 author: "John Lennon",
 category: nil
 ))
 
 // Preview with long quote
 QuoteCardView(quote: Quote(
 id: 3,
 quote: "The future belongs to those who believe in the beauty of their dreams and work tirelessly to make them a reality.",
 author: "Eleanor Roosevelt",
 category: "inspirational"
 ))
 }
 .padding()
 .background(Color(.systemGroupedBackground))
 .previewLayout(.sizeThatFits)
 }
 }
 */
