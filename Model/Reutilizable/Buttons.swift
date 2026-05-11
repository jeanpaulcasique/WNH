//
//  Buttons.swift
//  WNH
//

import SwiftUI

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.appYellow)
                .frame(width: 48, height: 48)
                .background(Color(white: 0.18))
                .clipShape(Circle())
        }
    }
}

// MARK: - Next Button
struct NextButton: View {
    let title: String
    let action: () -> Void
    @Binding var isLoading: Bool
    @Binding var isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(isDisabled ? Color.gray : Color.appYellow)
                    .shadow(color: isDisabled ? Color.clear : Color.appYellow.opacity(0.25), radius: 10, x: 0, y: 4)
            )
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(1.0)
    }
}