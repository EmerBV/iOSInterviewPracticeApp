//
//  CategoryChip.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.blue : Color(.systemGray5)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .cornerRadius(16)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}
