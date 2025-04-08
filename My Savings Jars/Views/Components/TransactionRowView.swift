//
//  TransactionRowView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
//import Savings_Jar

struct TransactionRowView: View {
    // The specific transaction to display
    let transaction: Transaction
    
    // A closure that formats a Double to a currency string
    let formatterString: (Double) -> String
    
    // Computed property to determine if this is a deposit (positive amount)
    private var isDeposit: Bool {
        return transaction.amount > 0
    }
    
    var body: some View {
        HStack {
            // Transaction icon and type indicator
            ZStack {
                // Colored background circle
                Circle()
                    .fill(isDeposit ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                // Directional arrow icon
                Image(systemName: isDeposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(isDeposit ? .green : .red)
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                // Transaction type text
                Text(isDeposit ? "Deposit" : "Withdrawal")
                    .font(.headline)
                
                // Transaction date
                Text(transaction.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Transaction amount
            Text(formatterString(abs(transaction.amount)))
                .font(.headline)
                .foregroundColor(isDeposit ? .green : .red)
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
