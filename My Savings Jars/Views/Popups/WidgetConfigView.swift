//
//  WidgetConfigView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI

struct WidgetConfigView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool

    private func getColor(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Widget Configuration")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                    ForEach(viewModel.savingsJars) { jar in
                        Button(action: {
                            isPresented = false
                        }) {
                            VStack {
                                Image(systemName: jar.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(getColor(jar.color))

                                Text(jar.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("$\(jar.currentAmount, specifier: "%.2f") / $\(jar.targetAmount, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(getColor(jar.color).opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button("Close") {
                isPresented = false
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
    }
}
