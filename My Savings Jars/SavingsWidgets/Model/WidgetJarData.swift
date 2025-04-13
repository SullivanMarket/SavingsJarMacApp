//
//  WidgetJarData.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

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

extension WidgetJarData {
    static let sample = WidgetJarData(
        id: UUID(),
        name: "Vacation",
        currentAmount: 750,
        targetAmount: 2000,
        color: "blue",
        icon: "airplane",
        progressPercentage: 0.375
    )
}
