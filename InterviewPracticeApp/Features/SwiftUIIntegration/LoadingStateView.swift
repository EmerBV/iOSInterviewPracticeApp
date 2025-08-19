//
//  LoadingStateView.swift
//  InterviewPracticeApp
//
//  Created by Emerson Balahan Varona on 19/8/25.
//

import SwiftUI

// MARK: - Loading State View
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Cargando citas inspiradoras...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
