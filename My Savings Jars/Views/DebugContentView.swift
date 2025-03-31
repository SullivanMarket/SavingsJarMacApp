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
        VStack {
            Text("Debug Console")
                .font(.title)
                .padding()

            Text(viewModel.debugMessage)
                .foregroundColor(.gray)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(Color.gray, width: 1)
                .padding()

            Button(action: {
                viewModel.debugMessage = "Debugging enabled at \(Date())"
            }) {
                Text("Log Debug Message")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: {
                addTestJar()
            }) {
                Text("Add Test Savings Jar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    private func addTestJar() {
        let testJar = SavingsJar(
            name: "Test Jar",
            targetAmount: 500,
            currentAmount: 100,
            color: "green",
            icon: "banknote.fill"
        )
        viewModel.savingsJars.append(testJar)
        viewModel.saveDataToUserDefaults()
    }
}

struct DebugContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        return DebugContentView().environmentObject(viewModel)
    }
}
