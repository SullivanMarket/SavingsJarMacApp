//
//  JarDetailView.swift
//  My Savings Jars
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
                    Text("\(Int(jar.percentComplete * 100))%")
                        .fontWeight(.bold)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .cornerRadius(8)

                    Rectangle()
                        .fill(Color.blue) // or use getColor(jar.color)
                        .frame(width: geometry.size.width * CGFloat(jar.percentComplete), height: 16)
                        .cornerRadius(8)
                }
            }
            .frame(height: 16)
            .padding(.vertical)

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
                        viewModel.savingsJars.remove(at: index)
                        viewModel.saveDataToUserDefaults()
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

struct JarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleJar = SavingsJar(
            id: UUID(),
            name: "Sample Jar",
            currentAmount: 750,
            targetAmount: 2000,
            color: "blue",
            icon: "dollarsign.circle",
            transactions: [],
            creationDate: Date()
        )
        let viewModel = SavingsViewModel()
        return JarDetailView(jar: sampleJar, viewModel: viewModel)
    }
}
