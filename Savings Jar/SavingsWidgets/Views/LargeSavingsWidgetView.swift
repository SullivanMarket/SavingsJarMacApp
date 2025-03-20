//
//  LargeSavingsWidgets.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI
import WidgetKit
import Foundation

struct LargeSavingsWidgetView: View {
    var entry: SavingsWidgetEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header - Total savings
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Savings")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(formattedCurrency(entry.content.totalSaved))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("of \(formattedCurrency(entry.content.totalTarget))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.content.totalProgress))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(entry.content.totalProgress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Divider
            Divider()
                .padding(.horizontal, 12)
            
            // List of jars
            if entry.content.allJars.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No Savings Jars")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                // Replace ScrollView with VStack
                VStack(spacing: 10) {
                    ForEach(entry.content.allJars.prefix(3)) { jar in
                        LargeWidgetJarRow(jar: jar)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Last updated info
            Text("Last updated: \(formattedDate(entry.date))")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
        }
    }
    
    // Format currency values
    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    // Format date for "last updated"
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Row for each savings jar in the large widget
struct LargeWidgetJarRow: View {
    var jar: WidgetJarData
    
    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(jar.getColor().opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: jar.icon)
                    .font(.system(size: 18))
                    .foregroundColor(jar.getColor())
            }
            
            // Jar details
            VStack(alignment: .leading, spacing: 4) {
                Text(jar.name)
                    .font(.system(size: 14, weight: .medium))
                
                HStack {
                    Text("\(Int(jar.percentComplete * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(jar.getColor())
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(formattedCurrency(jar.currentAmount)) of \(formattedCurrency(jar.targetAmount))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(jar.getColor().opacity(0.2), lineWidth: 4)
                    .frame(width: 32, height: 32)
                
                Circle()
                    .trim(from: 0, to: CGFloat(jar.percentComplete))
                    .stroke(jar.getColor(), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
            }
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
