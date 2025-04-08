//
//  AllJarsGridView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct AllJarsGridView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var selectedJarIndex: Int?

    let formatter = CurrencyFormatter.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("All Savings Jars")
                .font(.title)
                        .bold()
                        .italic()
                .padding(.top)
                .padding(.horizontal)
                .padding(.bottom, 10) // 👈 Adds spacing before scrollable content

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                    ForEach(viewModel.savingsJars) { jar in
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .center) {
                                Image(systemName: jar.icon)
                                    .foregroundColor(getColor(jar.color))
                                    .font(.title2)
                                    .frame(width: 30, height: 30)

                                Text(jar.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)

                                Spacer()
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(getColor(jar.color).opacity(0.2))
                                        .frame(height: 20)

                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(getColor(jar.color))
                                        .frame(width: max(4, geometry.size.width * CGFloat(jar.percentComplete)), height: 20)
                                }
                            }
                            .frame(height: 20)

                            HStack {
                                Text("\(formatter.string(from: jar.currentAmount)) / \(formatter.string(from: jar.targetAmount))")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundColor(.black)

                                Spacer()

                                Text(String(format: "%.1f%%", jar.percentComplete * 100))
                                    .font(.subheadline)
                                    .foregroundColor(getColor(jar.color))
                                    .fontWeight(.semibold)
                            }

                            Button(action: {
                                if let index = viewModel.savingsJars.firstIndex(where: { $0.id == jar.id }) {
                                    selectedJarIndex = index
                                }
                            }) {
                                Text("View")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(getColor(jar.color)))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
        }
    }

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
}
