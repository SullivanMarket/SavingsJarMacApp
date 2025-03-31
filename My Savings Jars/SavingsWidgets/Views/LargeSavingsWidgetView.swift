//
//  LargeSavingsWidgetView.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI
import WidgetKit

struct LargeSavingsWidgetView: View {
    var entry: SavingsWidgetEntry
    
    var body: some View {
        VStack {
            // Header with selected jar info
            if let selectedJar = entry.widgetData.selectedJar {
                HStack {
                    // Jar name and icon
                    HStack {
                        Image(systemName: selectedJar.icon)
                            .font(.system(size: 20))
                            .foregroundColor(getColor(selectedJar.color))
                        
                        Text(selectedJar.name)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Progress percentage
                    Text("\(Int(selectedJar.progressPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 20)
                            .opacity(0.3)
                            .foregroundColor(getColor(selectedJar.color))
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(selectedJar.progressPercentage), height: 20)
                            .foregroundColor(getColor(selectedJar.color))
                    }
                    .cornerRadius(10)
                }
                .frame(height: 20)
                .padding(.horizontal)
                
                // Amount details
                HStack {
                    // Current amount
                    VStack(alignment: .leading) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(selectedJar.currentAmount))
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    // Target amount
                    VStack(alignment: .trailing) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(selectedJar.targetAmount))
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // All jars list
            VStack(alignment: .leading) {
                Text("All Savings Jars")
                    .font(.headline)
                    .padding(.horizontal)
                
                if entry.widgetData.allJars.isEmpty {
                    HStack {
                        Spacer()
                        Text("No savings jars available")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                } else {
                    ForEach(entry.widgetData.allJars.prefix(4)) { jar in
                        HStack {
                            // Jar icon and name
                            Image(systemName: jar.icon)
                                .foregroundColor(getColor(jar.color))
                            Text(jar.name)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            // Mini progress bar
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: 50, height: 8)
                                    .opacity(0.3)
                                    .foregroundColor(getColor(jar.color))
                                
                                Rectangle()
                                    .frame(width: 50 * CGFloat(jar.progressPercentage), height: 8)
                                    .foregroundColor(getColor(jar.color))
                            }
                            .cornerRadius(4)
                            
                            // Percentage
                            Text("\(Int(jar.progressPercentage * 100))%")
                                .font(.caption)
                                .frame(width: 40, alignment: .trailing)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
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
