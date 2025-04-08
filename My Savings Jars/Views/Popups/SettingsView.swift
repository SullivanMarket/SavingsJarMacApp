//
//  SettingsView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Binding var isPresented: Bool
    @State private var tempSettings: Settings
    @Environment(\.colorScheme) var colorScheme
    
    // String state for the default target amount
    @State private var defaultTargetString: String = ""
    
    init(settingsManager: SettingsManager, isPresented: Binding<Bool>) {
        self.settingsManager = settingsManager
        self._isPresented = isPresented
        // Create a temporary copy of settings for editing
        self._tempSettings = State(initialValue: settingsManager.settings)
        // Initialize the target string (will be properly set in onAppear)
        self._defaultTargetString = State(initialValue: "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom title bar
            Color.blue
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("Settings")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Currency settings
                    GroupBox(label: Text("Currency").font(.headline)) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Currency")
                                    .frame(width: 120, alignment: .leading)
                                
                                Picker("", selection: $tempSettings.currencyCode) {
                                    ForEach(CurrencyOption.availableCurrencies) { currency in
                                        Text("\(currency.symbol) \(currency.name) (\(currency.code))")
                                            .tag(currency.code)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(minWidth: 200)
                                .labelsHidden()
                            }
                            
                            Toggle("Show cents", isOn: $tempSettings.showCents)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Default jar settings
                    GroupBox(label: Text("Default Settings for New Jars").font(.headline)) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Default Target Amount")
                                    .frame(width: 150, alignment: .leading)
                                
                                Spacer()
                                
                                // Use CurrencyField instead of TextField
                                CurrencyField(text: $defaultTargetString, placeholder: "Default Target")
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 160)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Default Color")
                                    .frame(width: 120, alignment: .leading)
                                
                                Picker("", selection: $tempSettings.defaultColor) {
                                    Text("Blue").tag("blue")
                                    Text("Purple").tag("purple")
                                    Text("Red").tag("red")
                                    Text("Green").tag("green")
                                    Text("Orange").tag("orange")
                                    Text("Yellow").tag("yellow")
                                }
                                .pickerStyle(.menu)
                                .frame(minWidth: 160)
                                .labelsHidden()
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Appearance settings
                    GroupBox(label: Text("Appearance").font(.headline)) {
                        VStack(alignment: .leading, spacing: 15) {
                            Toggle("Use Dark Mode", isOn: $tempSettings.useDarkMode)
                            Toggle("Compact View", isOn: $tempSettings.compactView)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Notification settings
                    GroupBox(label: Text("Notifications").font(.headline)) {
                        VStack(alignment: .leading, spacing: 15) {
                            Toggle("Notify on Milestones", isOn: $tempSettings.notifyOnMilestones)
                            
                            HStack {
                                Text("Reminder Frequency")
                                    .frame(width: 150, alignment: .leading)
                                
                                Picker("", selection: $tempSettings.reminderFrequency) {
                                    ForEach(ReminderFrequency.allCases) { frequency in
                                        Text(frequency.rawValue).tag(frequency)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(minWidth: 160)
                                .labelsHidden()
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Action buttons with new style matching the screenshot
                    HStack {
                        // Reset to Defaults button (gray)
                        Button {
                            tempSettings = Settings.default
                            defaultTargetString = CurrencyField.formatValue(tempSettings.defaultTarget)
                        } label: {
                            Text("Reset to Defaults")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(height: 36)
                                .frame(minWidth: 150)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.gray)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            // Cancel button (red)
                            Button {
                                isPresented = false
                            } label: {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.red)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Save button (blue)
                            Button {
                                // Parse the target amount from the string
                                if let targetAmount = Double(defaultTargetString.replacingOccurrences(of: ",", with: ".")) {
                                    tempSettings.defaultTarget = targetAmount
                                }
                                
                                // Save the temporary settings to the actual settings
                                settingsManager.settings = tempSettings
                                // Apply any immediate changes needed
                                settingsManager.applyAppearanceSettings()
                                isPresented = false
                            } label: {
                                Text("Save")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.blue)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .frame(width: 480, height: 600)
        .background(tempSettings.useDarkMode ? Color.black.opacity(0.9) : Color(.windowBackgroundColor))
        .cornerRadius(12)
        .preferredColorScheme(tempSettings.useDarkMode ? .dark : .light)
        .onAppear {
            // Initialize the defaultTargetString with the current value
            defaultTargetString = CurrencyField.formatValue(tempSettings.defaultTarget)
        }
    }
}
