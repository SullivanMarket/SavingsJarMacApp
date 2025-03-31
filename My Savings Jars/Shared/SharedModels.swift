//
//  SharedModels.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/23/25.
//

// SharedModels.swift
// Place this in your Shared folder and ensure it's included in BOTH targets

// Location: My Savings Jars/Shared/SharedModels.swift
import Foundation
import SwiftUI

// MARK: - WidgetJarData Model

public struct WidgetJarData: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var targetAmount: Double
    public var currentAmount: Double
    public var color: String
    public var icon: String
    
    // Computed property for percentage saved
    public var percentComplete: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    // Add this alongside the existing percentComplete property
    public var progressPercentage: Double {
        return percentComplete
    }
    
    // Direct initializer
    public init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        color: String,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.color = color
        self.icon = icon
    }
}

// MARK: - Transaction Model

public struct Transaction: Identifiable, Codable {
    public var id: UUID
    public var amount: Double
    public var date: Date
    public var note: String
    
    public init(id: UUID = UUID(), amount: Double, date: Date = Date(), note: String = "") {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
    
    // Computed property to check if transaction is a deposit
    public var isDeposit: Bool {
        return amount > 0
    }
}

// MARK: - SavingsJar Model

public struct SavingsJar: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var targetAmount: Double
    public var currentAmount: Double
    public var color: String
    public var icon: String
    public var creationDate: Date
    public var transactions: [Transaction]
    
    // Computed property for progress percentage (0.0 to 1.0)
    public var percentComplete: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    public var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    // Alias for percentComplete to maintain compatibility with existing code
    public var progress: Double {
        return percentComplete
    }
    
    // Computed property for total saved
    public var totalSaved: Double {
        return currentAmount
    }
    
    // Computed property for remaining amount
    public var remainingAmount: Double {
        return max(targetAmount - currentAmount, 0)
    }
    
    // Full initializer
    public init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        color: String,
        icon: String,
        creationDate: Date = Date(),
        transactions: [Transaction] = []
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.color = color
        self.icon = icon
        self.creationDate = creationDate
        self.transactions = transactions
    }
    
    // Simple initializer
    public init(
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        color: String,
        icon: String
    ) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.color = color
        self.icon = icon
        self.creationDate = Date()
        self.transactions = []
    }
    
    // Helper function to get Color from string
    public func getColor() -> Color {
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

// MARK: - PublicSavingsJar Model

public struct PublicSavingsJar: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var targetAmount: Double
    public var currentAmount: Double
    public var color: String
    public var icon: String
    public var creationDate: Date
    
    // Computed property for progress
    public var percentComplete: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    // Convert from full SavingsJar
    public init(from jar: SavingsJar) {
        self.id = jar.id
        self.name = jar.name
        self.targetAmount = jar.targetAmount
        self.currentAmount = jar.currentAmount
        self.color = jar.color
        self.icon = jar.icon
        self.creationDate = jar.creationDate
    }
    
    // Standard initializer
    public init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        color: String,
        icon: String,
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.color = color
        self.icon = icon
        self.creationDate = creationDate
    }
}

// MARK: - WidgetData Model

public struct WidgetData: Codable, Equatable {
    public var selectedJarID: UUID?
    public var allJars: [WidgetJarData]
    public var lastUpdated: Date
    
    // Define CodingKeys explicitly
    private enum CodingKeys: String, CodingKey {
        case selectedJarID
        case allJars
        case lastUpdated
    }
    
    // Custom encoder to handle date encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedJarID, forKey: .selectedJarID)
        try container.encode(allJars, forKey: .allJars)
        
        // Encode date as ISO8601 string
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: lastUpdated), forKey: .lastUpdated)
    }
    
    // Custom decoder to handle different date representations
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        selectedJarID = try container.decodeIfPresent(UUID.self, forKey: .selectedJarID)
        allJars = try container.decode([WidgetJarData].self, forKey: .allJars)
        
        // Robust date decoding
        if let doubleTimestamp = try? container.decode(Double.self, forKey: .lastUpdated) {
            // If it's a double timestamp (seconds since 1970)
            lastUpdated = Date(timeIntervalSince1970: doubleTimestamp)
        } else if let stringDate = try? container.decode(String.self, forKey: .lastUpdated) {
            // If it's a string date
            let formatter = ISO8601DateFormatter()
            lastUpdated = formatter.date(from: stringDate) ?? Date()
        } else {
            // Fallback to current date
            lastUpdated = Date()
        }
    }
    
    // Initializer
    public init(
        selectedJarID: UUID? = nil,
        allJars: [WidgetJarData],
        lastUpdated: Date = Date()
    ) {
        self.selectedJarID = selectedJarID
        self.allJars = allJars
        self.lastUpdated = lastUpdated
    }
    
    // Selected jar
    public var selectedJar: WidgetJarData? {
        if let id = selectedJarID {
            return allJars.first(where: { $0.id == id })
        }
        return allJars.first
    }
    
    // Total progress
    public var totalProgress: Double {
        let total = allJars.reduce(0.0) { $0 + $1.targetAmount }
        let current = allJars.reduce(0.0) { $0 + $1.currentAmount }
        return total > 0 ? min(current / total, 1.0) : 0.0
    }
    
    // Total saved
    public var totalSaved: Double {
        allJars.reduce(0.0) { $0 + $1.currentAmount }
    }
    
    // Total target
    public var totalTarget: Double {
        allJars.reduce(0.0) { $0 + $1.targetAmount }
    }
    
    // Equality comparison
    public static func == (lhs: WidgetData, rhs: WidgetData) -> Bool {
        lhs.selectedJarID == rhs.selectedJarID &&
        lhs.allJars.count == rhs.allJars.count &&
        lhs.lastUpdated == rhs.lastUpdated
    }
    
    // Sample data for previews
    public static let sample = WidgetData(
        selectedJarID: nil,
        allJars: [
            WidgetJarData(name: "Vacation", targetAmount: 2000, currentAmount: 750, color: "blue", icon: "airplane"),
            WidgetJarData(name: "New Phone", targetAmount: 1000, currentAmount: 350, color: "purple", icon: "iphone"),
            WidgetJarData(name: "Emergency Fund", targetAmount: 5000, currentAmount: 2000, color: "red", icon: "heart.circle")
        ]
    )
}
