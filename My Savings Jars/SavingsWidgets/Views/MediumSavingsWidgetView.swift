//
//  MediumSavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI
import WidgetKit

struct MediumSavingsWidgetView: View {
    var entry: SavingsWidgetEntry
    
    var body: some View {
        if let selectedJar = entry.widgetData.selectedJar {
            HStack {
                // Left side: Circular progress
                ZStack {
                    Circle()
                        .stroke(lineWidth: 12)
                        .opacity(0.3)
                        .foregroundColor(getColor(selectedJar.color))
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(selectedJar.progressPercentage, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                        .foregroundColor(getColor(selectedJar.color))
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    VStack {
                        Text("\(Int(selectedJar.progressPercentage * 100))%")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                    }
                }
                .padding()
                
                // Right side: Details
                VStack(alignment: .leading, spacing: 8) {
                    // Jar name and icon
                    HStack {
                        Image(systemName: selectedJar.icon)
                            .font(.system(size: 18))
                            .foregroundColor(getColor(selectedJar.color))
                        
                        Text(selectedJar.name)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Current amount
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(selectedJar.currentAmount))
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    // Target amount
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(selectedJar.targetAmount))
                        .font(.title3)
                }
                .padding(.trailing)
            }
        } else {
            HStack {
                Image(systemName: "banknote")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                
                Text("No Savings Jars Available")
                    .font(.headline)
            }
        }
    }
    
    // Helper function to convert color string to SwiftUI Color
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
    
    // Helper function to format currency
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}
