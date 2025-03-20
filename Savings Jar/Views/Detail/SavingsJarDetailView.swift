//
//  SavingsJarDetailView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
#if WIDGETS_ENABLED
import WidgetKit
#endif

struct SavingsJarDetailView: View {
    let jar: SavingsJar
    @ObservedObject var viewModel: SavingsViewModel
    @State private var showingDeleteConfirmation = false
    @State private var showWidgetConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var color: Color {
        viewModel.getColorFromString(jar.color)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 5) {
                    Text(jar.name)
                        .font(.fancyTitle)
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: jar.icon)
                                .font(.system(size: 35))
                                .foregroundColor(color)
                        }
                    }
                    .padding(.top, 5)
                }
                
                // Amount info
                VStack(spacing: 8) {
                    Text(viewModel.formatter.string(from: jar.currentAmount))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                    
                    Text("of \(viewModel.formatter.string(from: jar.targetAmount)) goal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressBar(value: jar.percentComplete, color: color)
                        .padding(.top, 5)
                    
                    Text(String(format: "%.1f%% Complete", jar.percentComplete * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Action buttons
                HStack(spacing: 20) {
                    Button {
                        viewModel.showTransactionFor(jar: jar)
                    } label: {
                        Label("Deposit / Withdraw", systemImage: "arrow.left.arrow.right.circle.fill")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    #if WIDGETS_ENABLED
                    // Widget button - only show if widgets are enabled
                    Button {
                        showWidgetConfirmation = true
                    } label: {
                        if viewModel.isSelectedForWidget(jar) {
                            Label("Featured in Widget", systemImage: "checkmark.circle.fill")
                                .frame(minWidth: 150)
                        } else {
                            Label("Show in Widget", systemImage: "apps.iphone")
                                .frame(minWidth: 150)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.isSelectedForWidget(jar) ? .green : .blue)
                    #endif
                }
                
                // Transaction history
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.fancyHeading)
                    
                    if jar.transactions.isEmpty {
                        Text("No transactions yet")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        let sortedTransactions = jar.transactions.sorted { $0.date > $1.date }
                        
                        ForEach(sortedTransactions.prefix(10)) { transaction in
                            TransactionRowView(transaction: transaction, formatter: viewModel.formatter)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Delete Jar button
                VStack {
                    Divider()
                        .padding(.vertical)
                    
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete Jar", systemImage: "trash")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.windowBackgroundColor).opacity(0.3))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .alert("Delete Savings Jar", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteSavingsJar(with: jar.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(jar.name)\"? This action cannot be undone.")
        }
        
        #if WIDGETS_ENABLED
        .alert(viewModel.isSelectedForWidget(jar) ? "Update Widget" : "Show in Widget", isPresented: $showWidgetConfirmation) {
            Button("Cancel", role: .cancel) {}
            if viewModel.isSelectedForWidget(jar) {
                Button("Remove from Widget", role: .destructive) {
                    viewModel.clearWidgetJarSelection()
                }
            } else {
                Button("Show in Widget") {
                    viewModel.selectJarForWidget(jar)
                }
            }
        } message: {
            if viewModel.isSelectedForWidget(jar) {
                Text("\"\(jar.name)\" is currently featured in the widget. Would you like to remove it?")
            } else {
                Text("Would you like to feature \"\(jar.name)\" in the Savings Jar widget? This will update all widgets on your home screen.")
            }
        }
        #endif
    }
}
