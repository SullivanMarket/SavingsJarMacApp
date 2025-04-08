//
//  SelectedJarDetailView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct SelectedJarDetailView: View {
    let jar: SavingsJar
    let formatter = CurrencyFormatter.shared
    @Binding var selectedJarIndex: Int?
    @Binding var showingEditJarPopup: Bool
    @Binding var showingTransactionsPopup: Bool
    @ObservedObject var viewModel: SavingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: jar.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(getColor(jar.color))

                VStack(alignment: .leading) {
                    Text(jar.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Created \(jar.creationDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(Color(.windowBackgroundColor))

            Divider()

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(getColor(jar.color).opacity(0.2))
                                .frame(height: 20)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(getColor(jar.color))
                                .frame(width: geometry.size.width * CGFloat(jar.percentComplete), height: 20)
                        }
                    }
                    .frame(height: 20)

                    HStack {
                        Text(formatter.string(from: jar.currentAmount))
                        Spacer()
                        Text(formatter.string(from: jar.targetAmount))
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(12)

                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.selectedJarForTransaction = jar
                        viewModel.showingTransactionPopup = true
                    }) {
                        Text("Deposit / Withdraw")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        viewModel.selectedJarForEditing = jar
                        showingEditJarPopup = true
                    }) {
                        Text("Edit Jar")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        if let index = viewModel.savingsJars.firstIndex(where: { $0.id == jar.id }) {
                            viewModel.deleteSavingsJar(at: IndexSet(integer: index))
                            selectedJarIndex = nil
                        }
                    }) {
                        Text("Delete Jar")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.red))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: {
                    showingTransactionsPopup = true
                }) {
                    Text("View Transactions")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(PlainButtonStyle())

                RecentTransactionsView(transactions: jar.transactions)
            }
            .padding()
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
