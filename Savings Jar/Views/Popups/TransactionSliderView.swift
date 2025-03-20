//
//  TransactionSliderView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct TransactionSliderView: View {
    let jar: SavingsJar
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isVisible: Bool
    
    @State private var isDeposit = true
    @State private var sliderValue: Double = 0
    @State private var customAmount: String = ""
    @State private var useCustomAmount = false
    
    var maxAmount: Double {
        isDeposit ? 1000 : jar.currentAmount
    }
    
    var color: Color {
        viewModel.getColorFromString(jar.color)
    }
    
    var actionColor: Color {
        isDeposit ? .green : .red
    }
    
    var effectiveAmount: Double {
        if useCustomAmount, let amount = Double(customAmount), amount >= 0 {
            return min(amount, maxAmount)
        } else {
            return sliderValue
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header and Close Button
            HStack {
                Text(jar.name)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    isVisible = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            
            // Toggle between deposit and withdraw
            Picker("Transaction Type", selection: $isDeposit) {
                Text("Deposit").tag(true)
                Text("Withdraw").tag(false)
            }
            .pickerStyle(.segmented)
            .onChange(of: isDeposit) { newValue, oldValue in
                // Reset slider value when changing modes
                sliderValue = 0
                customAmount = ""
            }
            
            // Toggle between slider and custom amount
            Toggle("Enter custom amount", isOn: $useCustomAmount)
                .padding(.top, 3)
            
            if useCustomAmount {
                // Custom amount input
                HStack {
                    TextField("Amount", text: $customAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Max: \(viewModel.formatter.string(from: maxAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                // Slider for amount
                VStack(spacing: 4) {
                    Slider(value: $sliderValue, in: 0...maxAmount)
                        .accentColor(actionColor)
                    
                    HStack {
                        Text("$0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(viewModel.formatter.string(from: maxAmount))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Display selected amount
            Text("\(isDeposit ? "Deposit" : "Withdraw") amount: \(viewModel.formatter.string(from: effectiveAmount))")
                .font(.headline)
                .foregroundColor(actionColor)
                .padding(.vertical, 8)
            
            // Action Buttons
            HStack(spacing: 15) {
                Button("Cancel") {
                    isVisible = false
                }
                .buttonStyle(.bordered)
                
                Button(isDeposit ? "Deposit" : "Withdraw") {
                    let amount = isDeposit ? effectiveAmount : -effectiveAmount
                    viewModel.updateSavingsJar(id: jar.id, amount: amount)
                    isVisible = false
                }
                .buttonStyle(.borderedProminent)
                .tint(actionColor)
                .disabled(effectiveAmount <= 0)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
