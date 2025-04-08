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

    @State private var showingDeleteConfirmation = false

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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
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

                // Progress
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)

                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let filled = CGFloat(jar.percentComplete) * width

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(getJarColor().opacity(0.2))
                                .frame(height: 20)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(getJarColor())
                                .frame(width: filled, height: 20)
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
                Button("Add Transaction") {
                    viewModel.selectedJarForTransaction = jar
                    viewModel.showingTransactionPopup = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(getJarColor())
                .foregroundColor(.white)
                .cornerRadius(10)

                // Transactions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Transactions")
                        .font(.headline)

                    if jar.transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(jar.transactions) { tx in
                            HStack {
                                Text(tx.date, style: .date)
                                Spacer()
                                Text("$\(tx.amount, specifier: "%.2f")")
                                    .foregroundColor(tx.amount >= 0 ? .green : .red)
                            }
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(5)
                        }
                    }
                }

                // Delete
                Button("Delete Jar") {
                    showingDeleteConfirmation = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .confirmationDialog("Are you sure?", isPresented: $showingDeleteConfirmation) {
            Button("Delete Jar", role: .destructive) {
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

struct SavingsJarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        let jar = SavingsJar(
            name: "Vacation Fund",
            currentAmount: 500,
            targetAmount: 1000,
            color: "blue",
            icon: "airplane"
        )
        return NavigationView {
            SavingsJarDetailView(viewModel: viewModel, jar: jar)
        }
    }
}
