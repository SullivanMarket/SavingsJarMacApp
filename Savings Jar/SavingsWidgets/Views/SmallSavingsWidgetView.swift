//
//  SmallSavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI
import WidgetKit

struct SmallSavingsWidgetView: View {
    var entry: SavingsWidgetEntry
    
    var body: some View {
        // Attempt to get selected jar from UserDefaults
        let selectedJarID = UserDefaults(suiteName: "group.com.sullivanmarket.savingsjar")?.string(forKey: "SelectedWidgetJarID")
        
        let displayJar = selectedJarID.flatMap { selectedID in
            entry.content.allJars.first(where: { $0.id.uuidString == selectedID })
        } ?? entry.content.selectedJar
        
        VStack(alignment: .leading, spacing: 6) {
            // Header with icon and name
            HStack {
                if let jar = displayJar {
                    Image(systemName: jar.icon)
                        .font(.system(size: 14))
                        .foregroundColor(jar.getColor())
                    
                    Text(jar.name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            Spacer()
            
            if let jar = displayJar {
                // Progress amount
                Text(formattedCurrency(jar.currentAmount))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(jar.getColor())
                
                // Target amount
                Text("of \(formattedCurrency(jar.targetAmount))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                // Progress bar
                WidgetProgressBar(
                    value: jar.percentComplete,
                    color: jar.getColor()
                )
                
                // Percentage text
                Text("\(Int(jar.percentComplete * 100))% Complete")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            } else {
                // No jars available
                Text("No Jar Selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }
    
    // Format currency values
    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// Progress bar for widget
struct WidgetProgressBar: View {
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .opacity(0.1)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(color)
            }
            .cornerRadius(4.0)
        }
        .frame(height: 8)
    }
}
