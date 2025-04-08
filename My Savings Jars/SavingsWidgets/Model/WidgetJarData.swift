//
//  WidgetJarData.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

// WidgetJarData.swift
import Foundation

struct WidgetJarData: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let currentAmount: Double
    let targetAmount: Double
    let color: String
    let icon: String
    let progressPercentage: Double
}
