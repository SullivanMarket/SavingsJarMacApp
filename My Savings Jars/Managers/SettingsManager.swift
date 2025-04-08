//
//  SettingsManager.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    // MARK: - Published Properties
    @Published var settings: Settings {
        didSet {
            saveSettings()
        }
    }
    
    // MARK: - Private Properties
    private let settingsKey = "com.sullivanmarket.savingsjar.settings"
    
    // MARK: - Initialization
    init() {
        // Load saved settings or use defaults
        self.settings = SettingsManager.loadSettings()
    }
    
    // MARK: - Settings Operations
    private static func loadSettings() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: "appSettings") else {
            return Settings.default
        }
        
        do {
            return try JSONDecoder().decode(Settings.self, from: data)
        } catch {
            print("Error loading settings: \(error.localizedDescription)")
            return Settings.default
        }
    }
    
    func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: settingsKey)
        } catch {
            print("Error saving settings: \(error.localizedDescription)")
        }
    }
    
    // Reset settings to default values
    func resetToDefaults() {
        settings = Settings.default
    }
    
    // MARK: - Settings Application
    func applyAppearanceSettings() {
        #if os(macOS)
        // On macOS, set the appearance for all windows
        NSApp.appearance = settings.useDarkMode ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
        #endif
    }
    
    // MARK: - Convenience Methods
    func getCurrencySymbol() -> String {
        return CurrencyOption.getSymbol(for: settings.currencyCode)
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = getNumberFormatter()
        return formatter.string(from: NSNumber(value: amount)) ?? "\(CurrencyOption.getSymbol(for: settings.currencyCode))\(amount)"
    }
    
    // Get a custom number formatter based on current settings
    func getNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = settings.currencyCode
        formatter.maximumFractionDigits = settings.showCents ? 2 : 0
        return formatter
    }
    
    // MARK: - Settings Updaters
    func updateCurrencyCode(_ code: String) {
        settings.currencyCode = code
        // No need to call saveSettings() here because of didSet observer
    }
    
    func toggleShowCents() {
        settings.showCents.toggle()
        // No need to call saveSettings() here because of didSet observer
    }
    
    func updateDefaultTarget(_ target: Double) {
        settings.defaultTarget = target
        // No need to call saveSettings() here because of didSet observer
    }
    
    func updateDefaultColor(_ color: String) {
        settings.defaultColor = color
        // No need to call saveSettings() here because of didSet observer
    }
    
    func toggleDarkMode() {
        settings.useDarkMode.toggle()
        applyAppearanceSettings()
        // No need to call saveSettings() here because of didSet observer
    }
    
    func toggleCompactView() {
        settings.compactView.toggle()
        // No need to call saveSettings() here because of didSet observer
    }
    
    func toggleNotifyOnMilestones() {
        settings.notifyOnMilestones.toggle()
        // No need to call saveSettings() here because of didSet observer
    }
    
    func updateReminderFrequency(_ frequency: ReminderFrequency) {
        settings.reminderFrequency = frequency
        // No need to call saveSettings() here because of didSet observer
    }
}
