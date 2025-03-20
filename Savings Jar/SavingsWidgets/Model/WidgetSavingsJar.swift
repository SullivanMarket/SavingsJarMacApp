//
//  WidgetSavingsJar.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import Foundation
import SwiftUI

// This is a simplified version of SavingsJar to use in widgets
// It only contains the data needed for displaying in widgets
struct WidgetSavingsJar: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var color: String
    var icon: String
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
    
    // Direct initialization constructor
    init(id: UUID, name: String, targetAmount: Double, currentAmount: Double, color: String, icon: String) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.color = color
        self.icon = icon
    }
    
    // Create from the full model
    init(from savingsJar: WidgetSavingsJarModel) {
        self.id = savingsJar.id
        self.name = savingsJar.name
        self.targetAmount = savingsJar.targetAmount
        self.currentAmount = savingsJar.currentAmount
        self.color = savingsJar.color
        self.icon = savingsJar.icon
    }
    
    // For testing and previews
    static let sampleJars = [
        WidgetSavingsJar(
            id: UUID(),
            name: "Vacation",
            targetAmount: 2000,
            currentAmount: 750,
            color: "blue",
            icon: "airplane"
        ),
        WidgetSavingsJar(
            id: UUID(),
            name: "New Phone",
            targetAmount: 1000,
            currentAmount: 350,
            color: "purple",
            icon: "iphone"
        ),
        WidgetSavingsJar(
            id: UUID(),
            name: "Emergency Fund",
            targetAmount: 5000,
            currentAmount: 2000,
            color: "red",
            icon: "heart.circle"
        )
    ]
    
    // Get a color from a string
    func getColor() -> Color {
        switch color {
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

// Widget configuration model
// Using internal (default) access level to match SavingsWidgetEntry
struct WidgetContent: Codable {
    var selectedJarID: UUID?
    var allJars: [WidgetSavingsJar]
    var lastUpdated: Date
    
    // Get the selected jar, or the first jar if none is selected
    var selectedJar: WidgetSavingsJar? {
        if let id = selectedJarID {
            return allJars.first(where: { $0.id == id })
        }
        return allJars.first
    }
    
    // Total progress for all jars
    var totalProgress: Double {
        let total = allJars.reduce(0.0) { $0 + $1.targetAmount }
        let current = allJars.reduce(0.0) { $0 + $1.currentAmount }
        return total > 0 ? min(current / total, 1.0) : 0.0
    }
    
    // Total saved amount
    var totalSaved: Double {
        return allJars.reduce(0.0) { $0 + $1.currentAmount }
    }
    
    // Total target amount
    var totalTarget: Double {
        return allJars.reduce(0.0) { $0 + $1.targetAmount }
    }
    
    // Sample content for previews
    static let sample = WidgetContent(
        selectedJarID: WidgetSavingsJar.sampleJars.first?.id,
        allJars: WidgetSavingsJar.sampleJars,
        lastUpdated: Date()
    )
}
