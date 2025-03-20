//
//  SavingsJarCard.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct SavingsJarCard: View {
    let jar: SavingsJar
    @ObservedObject var viewModel: SavingsViewModel
    let formatter = CurrencyFormatter.shared
    
    var color: Color {
        viewModel.getColorFromString(jar.color)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: jar.icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(jar.name)
                    .font(.headline)
                Spacer()
                
                Button {
                    viewModel.showTransactionFor(jar: jar)
                } label: {
                    Text("Deposit / Withdraw")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(color)
                }
                .buttonStyle(.plain)
                .help("Add or withdraw money")
            }
            
            Text(formatter.string(from: jar.currentAmount))
                .font(.title3)
                .fontWeight(.bold)
            
            ProgressBar(value: jar.percentComplete, color: color)
            
            HStack {
                Text("\(formatter.string(from: jar.currentAmount)) of \(formatter.string(from: jar.targetAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f%%", jar.percentComplete * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .cornerRadius(12)
    }
}
