//
//  SavingsJar.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import Foundation
import SwiftUI

// Savings Jar model with explicit Transaction type reference
struct SavingsJar: Identifiable, Codable {
    var id = UUID()
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var color: String // Store as string, convert to Color in the view
    var icon: String
    var creationDate = Date()
    var transactions: [Transaction] = []
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
    
    // Make a copy constructor for widget use
    func toWidgetJar() -> WidgetSavingsJar {
        return WidgetSavingsJar(
            id: self.id,
            name: self.name,
            targetAmount: self.targetAmount,
            currentAmount: self.currentAmount,
            color: self.color,
            icon: self.icon
        )
    }
    
    // CodingKeys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, name, targetAmount, currentAmount, color, icon, creationDate, transactions
    }
}

// Add this new struct at the end of the file
struct WidgetSavingsJar: Identifiable {
    let id: UUID
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let color: String
    let icon: String
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
    
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
