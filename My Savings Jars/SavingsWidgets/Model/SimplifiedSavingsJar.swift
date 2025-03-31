//
//  SimplifiedSavingsJar.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/19/25.
//

// Location: My Savings Jars/SavingsWidgets/Model/SimplifiedSavingsJar.swift
// Location: My Savings Jars/SavingsWidgets/Model/SimplifiedSavingsJar.swift
import Foundation
import SwiftUI
import WidgetKit

// MARK: - Simplified Savings Jar Model for Widget
struct SimplifiedSavingsJar: Identifiable, Codable, Hashable, Equatable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var color: String
    var icon: String
    var transactions: [Transaction]?
    
    // Computed property for progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    // Convenience initializer with default values
    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        color: String = "blue",
        icon: String = "jar",
        transactions: [Transaction]? = nil
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.color = color
        self.icon = icon
        self.transactions = transactions
    }
    
    // Helper function to get Color from string
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
    
    // Explicit Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(targetAmount)
        hasher.combine(currentAmount)
        hasher.combine(color)
        hasher.combine(icon)
    }
    
    // Explicit Equatable conformance
    static func == (lhs: SimplifiedSavingsJar, rhs: SimplifiedSavingsJar) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.targetAmount == rhs.targetAmount &&
               lhs.currentAmount == rhs.currentAmount &&
               lhs.color == rhs.color &&
               lhs.icon == rhs.icon
    }
    
    // Sample jar for previews
    static let sample = SimplifiedSavingsJar(
        name: "Vacation",
        targetAmount: 2000,
        currentAmount: 750,
        color: "blue",
        icon: "airplane"
    )
}
