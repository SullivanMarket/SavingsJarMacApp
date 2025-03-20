//
//  TransactionRowView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct TransactionRowView: View {
    // Explicitly use the Transaction type alias
    let transaction: Transaction
    let formatter: CurrencyFormatter
    // Create a date formatter here instead of in the body
    private let dateFormatter = createDateFormatter()
    
    var body: some View {
        HStack {
            Image(systemName: transaction.isDeposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(transaction.isDeposit ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(transaction.isDeposit ? "Deposit" : "Withdrawal")
                    .font(.subheadline)
                
                Text(dateFormatter.string(from: transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text((transaction.isDeposit ? "+" : "-") + formatter.string(from: abs(transaction.amount)))
                .font(.subheadline)
                .foregroundColor(transaction.isDeposit ? .green : .red)
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}
