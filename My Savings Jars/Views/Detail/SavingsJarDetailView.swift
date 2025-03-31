//
//  SavingsJarDetailView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct SavingsJarDetailView: View {
    @ObservedObject var viewModel: SavingsViewModel
    let jar: SavingsJar
    @Environment(\.presentationMode) var presentationMode
    
    // Helper method to get color
    private func getJarColor() -> Color {
        switch jar.color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    @State private var selectedAmount: String = ""
    @State private var isAddingTransaction = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Jar Header
                HStack {
                    Image(systemName: jar.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(getJarColor())
                    
                    VStack(alignment: .leading) {
                        Text(jar.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Created \(jar.creationDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Progress Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(getJarColor().opacity(0.2))
                                .frame(width: geometry.size.width, height: 20)
                                .cornerRadius(10)
                            
                            Rectangle()
                                .fill(getJarColor())
                                .frame(width: geometry.size.width * CGFloat(jar.percentComplete), height: 20)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 20)
                    
                    HStack {
                        Text("$\(jar.currentAmount, specifier: "%.2f")")
                        Spacer()
                        Text("/ $\(jar.targetAmount, specifier: "%.2f")")
                    }
                    .font(.subheadline)
                }
                
                // Transaction Button
                Button(action: {
                    // Directly set transaction properties
                    viewModel.selectedJarForTransaction = jar
                    viewModel.showingTransactionPopup = true
                }) {
                    Text("Add Transaction")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(getJarColor())
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Transactions List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Transactions")
                        .font(.headline)
                    
                    if jar.transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(jar.transactions) { transaction in
                            HStack {
                                Text(transaction.date, style: .date)
                                Spacer()
                                Text("$\(transaction.amount, specifier: "%.2f")")
                                    .foregroundColor(transaction.isDeposit ? .green : .red)
                            }
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                        }
                    }
                }
                
                // Delete Jar Button
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Text("Delete Jar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .confirmationDialog("Are you sure?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Jar", role: .destructive) {
                // Find the index of the jar and delete
                if let index = viewModel.savingsJars.firstIndex(where: { $0.id == jar.id }) {
                    viewModel.savingsJars.remove(at: index)
                    viewModel.saveDataToUserDefaults()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle(jar.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// Preview Provider
struct SavingsJarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        let sampleJar = SavingsJar(
            name: "Vacation Fund",
            targetAmount: 5000,
            currentAmount: 2500,
            color: "blue",
            icon: "airplane"
        )
        
        return NavigationView {
            SavingsJarDetailView(viewModel: viewModel, jar: sampleJar)
        }
    }
}
