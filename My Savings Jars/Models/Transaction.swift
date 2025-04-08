//
//  Transaction.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

import Foundation
// 👇 Add this to ensure Transaction is available
import SwiftUI

struct Transaction: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var amount: Double
    var date: Date
    var note: String
    var isDeposit: Bool
}
