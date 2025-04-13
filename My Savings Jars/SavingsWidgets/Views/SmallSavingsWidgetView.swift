//
//  SmallSavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI

struct SmallSavingsWidgetView: View {
    let jar: WidgetJarData
    let timestamp: Date

    var body: some View {
        VStack {
            Spacer(minLength: 8) // 🔼 Top buffer

            VStack(spacing: 8) {
                // App title
                Text("Savings Jars")
                    .font(.headline.italic())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Image(systemName: jar.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(getColor(jar.color))

                Text(jar.name)
                    .font(.subheadline)
                    .lineLimit(1)

                ProgressView(value: jar.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: getColor(jar.color)))

                Text("\(Int(jar.progressPercentage * 100))% saved")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("Updated \(timestamp.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()

            Spacer(minLength: 8) // 🔽 Bottom buffer
        }
    }

    private func getColor(_ color: String) -> Color {
        switch color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        default: return .blue
        }
    }
}
