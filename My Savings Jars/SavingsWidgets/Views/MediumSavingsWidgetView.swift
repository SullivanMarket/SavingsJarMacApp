//
//  MediumSavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI

struct MediumSavingsWidgetView: View {
    let jars: [WidgetJarData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if jars.isEmpty {
                Text("No jars selected for widget")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(jars.prefix(2), id: \.id) { jar in
                    HStack(spacing: 10) {
                        Image(systemName: jar.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(getColor(jar.color))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(jar.name)
                                .font(.headline)
                                .lineLimit(1)

                            ProgressView(value: jar.progressPercentage)
                                .progressViewStyle(LinearProgressViewStyle(tint: getColor(jar.color)))

                            Text("\(Int(jar.progressPercentage * 100))% saved")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                }
            }

            Spacer()
        }
        .padding()
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
