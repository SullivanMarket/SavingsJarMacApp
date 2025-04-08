//
//  SmallSavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI

struct SmallSavingsWidgetView: View {
    let jar: WidgetJarData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: jar.icon)
                    .font(.headline)
                Text(jar.name)
                    .font(.headline)
                    .lineLimit(1)
            }
            .padding(.bottom, 2)

            Text("$\(Int(jar.currentAmount))")
                .font(.system(size: 24, weight: .bold))

            Text("of $\(Int(jar.targetAmount))")
                .font(.caption)
                .foregroundColor(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.2)
                        .foregroundColor(getColor(jar.color))

                    Rectangle()
                        .frame(width: CGFloat(jar.progressPercentage) * geometry.size.width, height: 8)
                        .foregroundColor(getColor(jar.color))
                }
                .cornerRadius(4)
            }
            .frame(height: 8)

            Text("\(Int(jar.progressPercentage * 100))% saved")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

// Place this *outside* of the SmallSavingsWidgetView struct

private func getColor(_ colorString: String) -> Color {
    switch colorString {
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
