//
//  Transaction.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import Foundation

// Adding a namespace to avoid ambiguity
enum Models {
    // Transaction model for tracking deposits and withdrawals
    struct Transaction: Identifiable, Codable {
        var id = UUID()
        var amount: Double
        var date: Date
        var isDeposit: Bool {
            return amount > 0
        }
        
        // CodingKeys to ensure proper encoding/decoding
        enum CodingKeys: String, CodingKey {
            case id, amount, date
        }
    }
}

// Type alias for easier referencing throughout the app
typealias Transaction = Models.Transaction
