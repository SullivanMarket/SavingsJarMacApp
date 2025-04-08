//
//  MainContentView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct MainContentView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var selectedJarIndex: Int?
    @Binding var sidebarExpanded: Bool
    @Binding var showingEditJarPopup: Bool
    @Binding var showingTransactionsPopup: Bool

    let formatter = CurrencyFormatter.shared

    var totalSaved: Double {
        viewModel.savingsJars.reduce(0) { $0 + $1.currentAmount }
    }

    var totalTarget: Double {
        viewModel.savingsJars.reduce(0) { $0 + $1.targetAmount }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .frame(height: 60)
                .edgesIgnoringSafeArea(.top)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Total Savings")
                        .font(.title)
                        .bold()
                        .italic()

                    Spacer()

                    if !sidebarExpanded {
                        Button(action: {
                            withAnimation {
                                sidebarExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "sidebar.right")
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(height: 60)
                .padding(.horizontal)
                .background(Color(red: 0.4, green: 0.4, blue: 0.8))
                .contentShape(Rectangle())

                // TOTAL SAVINGS OVERVIEW
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Progress")
                                .font(.headline)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(height: 20)

                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                        .frame(width: geometry.size.width * CGFloat(min(1, totalSaved / totalTarget)), height: 20)
                                }
                            }
                            .frame(height: 20)

                            HStack {
                                Text("\(formatter.string(from: totalSaved)) of \(formatter.string(from: totalTarget))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text(String(format: "%.1f%%", totalTarget > 0 ? (totalSaved / totalTarget * 100) : 0))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Text(formatter.string(from: totalSaved))
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.windowBackgroundColor))

                Divider()

                // SELECTED JAR DETAILS OR ALL JARS
                if let selectedIndex = selectedJarIndex, selectedIndex < viewModel.savingsJars.count {
                    SelectedJarDetailView(
                        jar: viewModel.savingsJars[selectedIndex],
                        selectedJarIndex: $selectedJarIndex,
                        showingEditJarPopup: $showingEditJarPopup,
                        showingTransactionsPopup: $showingTransactionsPopup,
                        viewModel: viewModel
                    )
                } else {
                    AllJarsGridView(
                        viewModel: viewModel,
                        selectedJarIndex: $selectedJarIndex
                    )
                }
            }
        }
    }
}
