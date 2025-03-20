//
//  SettingsManager.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import Foundation
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    // Published settings that UI can observe
    @Published var settings: Settings {
        didSet {
            saveSettings()
        }
    }
    
    private let settingsKey = "com.sullivanmarket.savingsjar.settings"
    
    init() {
        // Load saved settings or use defaults
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let savedSettings = try? JSONDecoder().decode(Settings.self, from: data) {
            self.settings = savedSettings
        } else {
            self.settings = Settings.default
        }
    }
    
    // Save settings to UserDefaults
    private func saveSettings() {
        if let encodedData = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encodedData, forKey: settingsKey)
        }
    }
    
    // Reset settings to default values
    func resetToDefaults() {
        settings = Settings.default
    }
    
    // Get a custom number formatter based on current settings
    func getNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = settings.currencyCode
        formatter.maximumFractionDigits = settings.showCents ? 2 : 0
        return formatter
    }
    
    // Apply theme based on dark mode setting
    func applyAppearanceSettings() {
        #if os(macOS)
        // On macOS, set the appearance for all windows
        NSApp.appearance = settings.useDarkMode ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
        #endif
    }
}
