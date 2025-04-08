//
//  RecentTransactionsView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [SavingsTransaction]
    let formatter = CurrencyFormatter.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Transactions")
                .font(.headline)

            if transactions.isEmpty {
                Text("No transactions yet")
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(transactions.prefix(5)) { transaction in
                            HStack {
                                Image(systemName: transaction.amount > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .foregroundColor(transaction.amount > 0 ? .green : .red)

                                Text(transaction.date, style: .date)
                                    .font(.subheadline)

                                Spacer()

                                Text(formatter.string(from: abs(transaction.amount)))
                                    .fontWeight(.medium)
                                    .foregroundColor(transaction.amount > 0 ? .green : .red)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(maxHeight: 180) // Adjust to taste
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .cornerRadius(12)
    }
}
