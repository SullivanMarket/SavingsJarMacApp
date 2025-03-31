//
//  ContentView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack {
            Text("My Savings Jars")
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(viewModel.savingsJars) { jar in
                    HStack {
                        Image(systemName: jar.icon)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(getColor(jar.color))
                        
                        VStack(alignment: .leading) {
                            Text(jar.name)
                                .font(.headline)
                            Text("Saved: $\(jar.currentAmount, specifier: "%.2f") / $\(jar.targetAmount, specifier: "%.2f")")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.selectedJarForEditing = jar
                            viewModel.showingEditJarPopup = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(8)
                }
                .onDelete(perform: viewModel.deleteSavingsJar)
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                viewModel.selectedJarForEditing = SavingsJar(name: "", targetAmount: 0, currentAmount: 0, color: "blue", icon: "dollarsign.circle")
                viewModel.showingEditJarPopup = true
            }) {
                Text("Add New Jar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showingEditJarPopup) {
            if let jar = viewModel.selectedJarForEditing {
                EditJarView(viewModel: viewModel, jar: jar, isPresented: $viewModel.showingEditJarPopup)
            }
        }
    }
    
    private func getColor(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        let settingsManager = SettingsManager()
        
        return ContentView(viewModel: viewModel, settingsManager: settingsManager)
    }
}
