//
//  DebugContentView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/25/25.
//

import SwiftUI

struct DebugContentView: View {
    @EnvironmentObject var viewModel: SavingsViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Debug Console")
                .font(.title)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.savingsJars) { jar in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(jar.name)")
                                .font(.headline)
                            Text("ID: \(jar.id.uuidString)")
                                .font(.caption)
                            Text("Current: $\(jar.currentAmount, specifier: "%.2f"), Target: $\(jar.targetAmount, specifier: "%.2f")")
                                .font(.caption2)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            HStack(spacing: 16) {
                Button("Add Test Jar") {
                    let testJar = SavingsJar(
                        name: "Test",
                        currentAmount: 100,
                        targetAmount: 500,
                        color: "blue",
                        icon: "star.fill"
                    )
                    viewModel.addSavingsJar(testJar)
                }

                Button("Clear All Jars") {
                    viewModel.savingsJars.removeAll()
                    viewModel.saveDataToUserDefaults()
                }
            }
            .padding(.bottom)
        }
        .padding()
    }
}

struct DebugContentView_Previews: PreviewProvider {
    static var previews: some View {
        DebugContentView().environmentObject(SavingsViewModel())
    }
}
