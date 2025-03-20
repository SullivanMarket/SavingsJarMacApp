//
//  SimplifiedSavingsJar.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/19/25.
//

// SimplifiedSavingsJar.swift
import Foundation
import SwiftUI

// A simplified version of SavingsJar for widget use
struct WidgetSavingsJarModel: Codable, Identifiable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var color: String
    var icon: String
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
}
