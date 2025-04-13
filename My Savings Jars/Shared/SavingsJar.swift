//
//  SavingsJar.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

import Foundation


struct SavingsTransaction: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let amount: Double
    let note: String
}

struct SavingsJar: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var currentAmount: Double
    var targetAmount: Double
    var color: String
    var icon: String
    var transactions: [SavingsTransaction] = []
    var creationDate: Date = Date()

    // ✅ Updated initializer
    init(
        id: UUID = UUID(),
        name: String,
        currentAmount: Double,
        targetAmount: Double,
        color: String,
        icon: String,
        transactions: [SavingsTransaction] = [],
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.currentAmount = currentAmount
        self.targetAmount = targetAmount
        self.color = color
        self.icon = icon
        self.transactions = transactions
        self.creationDate = creationDate
    }
}

extension SavingsJar {
    static let sample = SavingsJar(
        id: UUID(),
        name: "Vacation Fund",
        currentAmount: 500,
        targetAmount: 1000,
        color: "blue",
        icon: "airplane",
        transactions: [
            SavingsTransaction(id: UUID(), date: Date().addingTimeInterval(-86400 * 5), amount: 250, note: "Initial deposit"),
            SavingsTransaction(id: UUID(), date: Date().addingTimeInterval(-86400 * 2), amount: 250, note: "Bonus")
        ],
        creationDate: Date().addingTimeInterval(-86400 * 10)
    )

    var percentComplete: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
}
