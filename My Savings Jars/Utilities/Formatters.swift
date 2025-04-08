//
//  Formatters.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import Foundation
import SwiftUI

// MARK: - Formatters
class CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private var numberFormatter: NumberFormatter
    private var settingsManager: SettingsManager?
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
    }
    
    // Connect the formatter to settings manager to respect user preferences
    func configure(with settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        updateFormatterFromSettings()
    }
    
    private func updateFormatterFromSettings() {
        guard let settings = settingsManager?.settings else { return }
        
        numberFormatter.currencyCode = settings.currencyCode
        numberFormatter.maximumFractionDigits = settings.showCents ? 2 : 0
    }
    
    func string(from value: Double) -> String {
        // Update from settings if available before formatting
        if let _ = settingsManager {
            updateFormatterFromSettings()
        }
        return numberFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// Create a date formatter for reuse
func createDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}
