//
//  ButtonExtensions.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/29/25.
//

import SwiftUI

// Extension for pill button style - centralized for the entire app
extension Button {
    func pillStyle(_ color: Color, isDisabled: Bool = false) -> some View {
        self
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isDisabled ? color.opacity(0.5) : color)
            )
            .opacity(isDisabled ? 0.7 : 1.0)
            .disabled(isDisabled)
    }
}
