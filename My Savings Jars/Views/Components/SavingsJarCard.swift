//
//  SavingsJarCard.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

struct SavingsJarCard: View {
    // Use @ObservedObject and pass the view model
    @ObservedObject var viewModel: SavingsViewModel
    let jar: SavingsJar
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Jar Name
                Text(jar.name)
                    .font(.headline)
                
                Spacer()
                
                // Jar Icon
                Image(systemName: jar.icon)
                    .foregroundColor(getJarColor())
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(getJarColor().opacity(0.2))
                        .frame(width: geometry.size.width, height: 20)
                        .cornerRadius(10)
                    
                    // Progress
                    Rectangle()
                        .fill(getJarColor())
                        .frame(width: geometry.size.width * CGFloat(jar.percentComplete), height: 20)
                        .cornerRadius(10)
                }
            }
            .frame(height: 20)
            
            // Amount Details
            HStack {
                Text("$\(jar.currentAmount, specifier: "%.2f")")
                    .font(.subheadline)
                
                Spacer()
                
                Text("/ $\(jar.targetAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Add Transaction Button
            Button(action: {
                // Directly call the method on the view model
                viewModel.selectedJarForTransaction = jar
                viewModel.showingTransactionPopup = true
            }) {
                Text("Add Transaction")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(getJarColor())
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Preview Provider
struct SavingsJarCard_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SavingsViewModel()
        let sampleJar = SavingsJar(
            name: "Vacation Fund",
            currentAmount: 2500, // <-- this goes first now
            targetAmount: 5000,
            color: "blue",
            icon: "airplane"
        )
        
        return SavingsJarCard(viewModel: viewModel, jar: sampleJar)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
