//
//  TransactionSliderView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/29/25.
//

import SwiftUI

struct TransactionSliderView: View {
    @ObservedObject var viewModel: SavingsViewModel
    let jar: SavingsJar
    @Binding var isPresented: Bool
    
    @State private var transactionType: TransactionType = .deposit
    @State private var amountString: String = ""
    @State private var note: String = ""
    @State private var showErrorAlert = false
    
    enum TransactionType {
        case deposit
        case withdraw
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Bar with bigger text
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .overlay(
                    Text("Transaction")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Content
            VStack(spacing: 24) {
                // Transaction type selector
                HStack(spacing: 0) {
                    Button(action: {
                        transactionType = .deposit
                    }) {
                        Text("Deposit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(transactionType == .deposit ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(transactionType == .deposit ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        transactionType = .withdraw
                    }) {
                        Text("Withdraw")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(transactionType == .withdraw ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(transactionType == .withdraw ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(8)
                .padding(.top, 15)
                
                // Jar Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(jar.name)
                            .font(.headline)
                        
                        Text("Current Balance: $\(jar.currentAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: jar.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                // Amount field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    CurrencyField(text: $amountString, placeholder: "Enter amount")
                        .padding()
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                // Note field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note (Optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter note", text: $note)
                        .padding()
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                Spacer(minLength: 20) // Add flexible space
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(Color.red))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        processTransaction()
                    }) {
                        Text(transactionType == .deposit ? "Deposit" : "Withdraw")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Capsule().fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(amountString.isEmpty)
                    .opacity(amountString.isEmpty ? 0.7 : 1.0)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .frame(width: 400, height: 550)
        .clipped() // Ensures content stays within bounds
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Insufficient Funds"),
                message: Text("You cannot withdraw more than the current balance"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Set default amount if needed
            if amountString.isEmpty {
                amountString = "0.00"
            }
        }
    }
    
    private func processTransaction() {
        guard let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) else { return }
        
        if transactionType == .deposit {
            // Process deposit
            let newTransaction = Transaction(
                amount: amount,
                date: Date(),
                note: note
            )
            viewModel.addSavingsTransaction(to: jar, transaction: newTransaction)
        } else {
            // Process withdrawal - only if there's enough balance
            if amount <= jar.currentAmount {
                let newTransaction = Transaction(
                    amount: -amount, // Negative amount for withdrawal
                    date: Date(),
                    note: note
                )
                viewModel.addSavingsTransaction(to: jar, transaction: newTransaction)
            } else {
                // Show error alert that withdrawal exceeds balance
                showErrorAlert = true
                return
            }
        }
        
        // Close the sheet
        isPresented = false
    }
}
