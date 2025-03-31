//
//  JarDetailView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct JarDetailView: View {
    let jar: SavingsJar
    @ObservedObject var viewModel: SavingsViewModel
    
    @State private var showingTransactionPopup = false
    @State private var showingEditJarPopup = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(jar.name)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Current Amount:")
                        .fontWeight(.medium)
                    Text("$\(jar.currentAmount, specifier: "%.2f")")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Target Amount:")
                        .fontWeight(.medium)
                    Text("$\(jar.targetAmount, specifier: "%.2f")")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Progress:")
                        .fontWeight(.medium)
                    Text("\(Int(jar.progressPercentage))%")
                        .fontWeight(.bold)
                }
            }
            
            ProgressView(value: jar.progressPercentage, total: 100)
                .frame(height: 16)
                .padding(.vertical)
            
            // 🏦 Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    showingTransactionPopup = true
                }) {
                    Label("Deposit / Withdraw", systemImage: "arrow.up.arrow.down.circle.fill")
                }
                .buttonStyle(DefaultButtonStyle())
                
                Button(action: {
                    showingEditJarPopup = true
                }) {
                    Label("Edit", systemImage: "pencil.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    if let index = viewModel.savingsJars.firstIndex(where: { $0.id == jar.id }) {
                        viewModel.deleteSavingsJar(at: IndexSet(integer: index))
                    }
                }) {
                    Label("Delete", systemImage: "trash.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.red)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingTransactionPopup) {
            TransactionSliderView(viewModel: viewModel, jar: jar, isPresented: $showingTransactionPopup)
        }
        .sheet(isPresented: $showingEditJarPopup) {
            EditJarView(viewModel: viewModel, jar: jar, isPresented: $showingEditJarPopup)
        }
    }
}

// 📌 Preview
struct JarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleJar = SavingsJar(
            id: UUID(),
            name: "Sample Jar",
            targetAmount: 2000,
            currentAmount: 750,
            color: "blue",
            icon: "dollarsign.circle",
            creationDate: Date(),
            transactions: []
        )
        let viewModel = SavingsViewModel()
        return JarDetailView(jar: sampleJar, viewModel: viewModel)
    }
}
