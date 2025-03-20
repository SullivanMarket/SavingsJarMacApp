//
//  Settings.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import Foundation
import SwiftUI

// Settings model to store user preferences
struct Settings: Codable, Equatable {
    // Currency preferences
    var currencyCode: String
    var showCents: Bool
    
    // Default values for new jars
    var defaultTarget: Double
    var defaultColor: String
    
    // App appearance
    var useDarkMode: Bool
    var compactView: Bool
    
    // Notifications
    var notifyOnMilestones: Bool
    var reminderFrequency: ReminderFrequency
    
    // Default settings
    static let `default` = Settings(
        currencyCode: "USD",
        showCents: true,
        defaultTarget: 1000,
        defaultColor: "blue",
        useDarkMode: false,
        compactView: false,
        notifyOnMilestones: true,
        reminderFrequency: .weekly
    )
}

// Reminder frequency options
enum ReminderFrequency: String, Codable, CaseIterable, Identifiable {
    case never = "Never"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
}

// Currency options
struct CurrencyOption: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String
    
    static let availableCurrencies: [CurrencyOption] = [
        CurrencyOption(code: "USD", name: "US Dollar", symbol: "$"),
        CurrencyOption(code: "EUR", name: "Euro", symbol: "€"),
        CurrencyOption(code: "GBP", name: "British Pound", symbol: "£"),
        CurrencyOption(code: "JPY", name: "Japanese Yen", symbol: "¥"),
        CurrencyOption(code: "CAD", name: "Canadian Dollar", symbol: "$"),
        CurrencyOption(code: "AUD", name: "Australian Dollar", symbol: "$")
    ]
    
    static func getSymbol(for code: String) -> String {
        return availableCurrencies.first(where: { $0.code == code })?.symbol ?? "$"
    }
}
