//
//  SavingsOverviewView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct SavingsOverviewView: View {
    let savingsJars: [SavingsJar]
    @ObservedObject var viewModel: SavingsViewModel
    let formatter = CurrencyFormatter.shared
    
    var totalSaved: Double {
        savingsJars.reduce(0) { $0 + $1.currentAmount }
    }
    
    var totalTarget: Double {
        savingsJars.reduce(0) { $0 + $1.targetAmount }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Total Savings")
                    .font(.fancyTitle)
                    .padding(.top)
                
                // Total savings card
                VStack(spacing: 15) {
                    HStack {
                        Text("Total Progress")
                            .font(.headline)
                        Spacer()
                        Text(formatter.string(from: totalSaved))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    ProgressBar(progress: totalSaved / totalTarget, color: .blue)
                    
                    HStack {
                        Text("\(formatter.string(from: totalSaved)) of \(formatter.string(from: totalTarget))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", (totalSaved / totalTarget) * 100))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(12)
                
                Text("All Savings Jars")
                    .font(.fancyHeading)
                    .padding(.top)
                
                // Grid of savings jars
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                    ForEach(savingsJars) { jar in
                        // Use the viewModel for the SavingsJarCard
                        SavingsJarCard(viewModel: viewModel, jar: jar)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

struct SavingsOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        
        return SavingsOverviewView(
            savingsJars: [
                SavingsJar(
                    name: "Vacation",
                    targetAmount: 2000,
                    currentAmount: 750,
                    color: "blue",
                    icon: "airplane"
                ),
                SavingsJar(
                    name: "New Phone",
                    targetAmount: 1000,
                    currentAmount: 350,
                    color: "purple",
                    icon: "iphone"
                )
            ],
            viewModel: viewModel
        )
    }
}
