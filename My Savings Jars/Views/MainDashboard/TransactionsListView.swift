//
//  TransactionsListView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct TransactionsListView: View {
    @ObservedObject var viewModel: SavingsViewModel
    let jar: SavingsJar
    @Binding var isPresented: Bool

    let formatter = CurrencyFormatter.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .overlay(
                    Text("\(jar.name) Transactions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )

            VStack(spacing: 16) {
                HStack {
                    Image(systemName: jar.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(getColor(jar.color))

                    VStack(alignment: .leading) {
                        Text(jar.name)
                            .font(.headline)
                        Text("Current Balance: \(formatter.string(from: jar.currentAmount))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.selectedJarForTransaction = jar
                        viewModel.showingTransactionPopup = true
                        isPresented = false
                    }) {
                        Text("New Transaction")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Divider()

                if jar.transactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("No Transactions Yet")
                            .font(.headline)

                        Text("Add a deposit or withdrawal to get started")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(jar.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(transaction.amount > 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                                .frame(width: 40, height: 40)

                                            Image(systemName: transaction.amount > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                                .foregroundColor(transaction.amount > 0 ? .green : .red)
                                        }

                                        VStack(alignment: .leading) {
                                            Text(transaction.amount > 0 ? "Deposit" : "Withdrawal")
                                                .font(.headline)
                                            Text(transaction.date, style: .date)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Text(formatter.string(from: abs(transaction.amount)))
                                            .font(.headline)
                                            .foregroundColor(transaction.amount > 0 ? .green : .red)
                                    }

                                    if !transaction.note.isEmpty {
                                        Text(transaction.note)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 65)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Button(action: {
                    isPresented = false
                }) {
                    Text("Close")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .frame(width: 500, height: 650)
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
