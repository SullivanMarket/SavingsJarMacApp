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
        HStack(alignment: .top, spacing: 16) {
            // Left side - Selected jar or total
            VStack(alignment: .leading, spacing: 6) {
                if let jar = entry.content.selectedJar {
                    // Single Jar View
                    HStack {
                        Image(systemName: jar.icon)
                            .font(.system(size: 16))
                            .foregroundColor(jar.getColor())
                        
                        Text(jar.name)
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Progress amount
                    Text(formattedCurrency(jar.currentAmount))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(jar.getColor())
                    
                    // Target amount
                    Text("of \(formattedCurrency(jar.targetAmount))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    // Progress bar
                    WidgetProgressBar(
                        value: jar.percentComplete,
                        color: jar.getColor()
                    )
                    .padding(.top, 2)
                    
                    // Percentage text
                    Text("\(Int(jar.percentComplete * 100))% Complete")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                } else {
                    // No jars available
                    VStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                        
                        Text("No Savings Jars")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            
            Divider()
            
            // Right side - List of jars
            VStack(alignment: .leading, spacing: 6) {
                Text("All Jars")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.bottom, 4)
                
                if entry.content.allJars.isEmpty {
                    Text("No savings jars found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                } else {
                    ForEach(entry.content.allJars.prefix(3)) { jar in
                        HStack {
                            Circle()
                                .fill(jar.getColor())
                                .frame(width: 10, height: 10)
                            
                            Text(jar.name)
                                .font(.system(size: 12))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(formattedCurrency(jar.currentAmount))
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Spacer()
                    
                    // Total saved
                    HStack {
                        Text("Total Saved:")
                            .font(.system(size: 12, weight: .medium))
                        
                        Spacer()
                        
                        Text(formattedCurrency(entry.content.totalSaved))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
        }
    }
    
    // Format currency values
    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
