//
//  SavingsJarApp.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI

@main
struct SavingsJarApp: App {
    // Create the settings manager at the app level so it persists
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("")
                .environmentObject(settingsManager)
                .onAppear {
                    // Apply appearance settings when app launches
                    settingsManager.applyAppearanceSettings()
                }
        }
        .windowStyle(.hiddenTitleBar) // Give the app a more modern look
    }
}
