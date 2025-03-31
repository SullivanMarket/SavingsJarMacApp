//
//  SavingsJarApp.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
import WidgetKit
import Combine

@main
struct SavingsJarApp: App {
    // Create the settings manager at the app level so it persists
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var viewModel = SavingsViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainDashboardView(viewModel: viewModel, settingsManager: settingsManager)
                .navigationTitle("")
                .environmentObject(settingsManager)
                .environmentObject(viewModel)
                .onAppear {
                    // Apply appearance settings when app launches
                    settingsManager.applyAppearanceSettings()
                    
                    // Load and update widget data when app launches
                    viewModel.loadDataFromUserDefaults()
                    
                    // Log debug info
                    print("🔄 App launched with \(viewModel.savingsJars.count) jars")
                }
                .onOpenURL { url in
                    // Handle URL when app is opened from a widget
                    processWidgetLaunch(url: url)
                }
        }
        .windowStyle(.hiddenTitleBar) // Give the app a more modern look
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("🔄 Scene phase changed: \(oldPhase) -> \(newPhase)")
            
            if newPhase == .background {
                // Important: Save all data when app goes to background
                print("💾 App entering background - saving data")
                viewModel.saveDataToUserDefaults()
            } else if newPhase == .active && oldPhase == .background {
                // Reload data when becoming active from background
                print("🔄 App becoming active from background - reloading data")
                viewModel.loadDataFromUserDefaults()
            }
        }
        
        #if os(macOS)
        // Add macOS-specific settings
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Save Data") {
                    viewModel.saveDataToUserDefaults()
                }
                .keyboardShortcut("s", modifiers: [.command])
                
                Button("Debug Panel") {
                    NotificationCenter.default.post(name: Notification.Name("ToggleDebugPanel"), object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command, .option])
            }
        }
        #endif
    }
    
    // Separate method to handle widget launch
    private func processWidgetLaunch(url: URL) {
        print("📱 App launched from widget with URL: \(url)")
        
        // Parse the URL to extract the jar ID if present
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let action = components.host {
            
            switch action {
            case "viewJar":
                // Extract jar ID from URL query parameters
                if let jarIdParam = components.queryItems?.first(where: { $0.name == "id" })?.value,
                   let jarId = UUID(uuidString: jarIdParam) {
                    // Set the selected jar
                    viewModel.selectedJarId = jarId
                    print("🔍 Selected jar from widget: \(jarId)")
                }
                
            case "addTransaction":
                // Handle transaction request
                if let jarIdParam = components.queryItems?.first(where: { $0.name == "id" })?.value,
                   let jarId = UUID(uuidString: jarIdParam),
                   let jar = viewModel.savingsJars.first(where: { $0.id == jarId }) {
                    // Show transaction UI for this jar
                    viewModel.selectedJarForTransaction = jar
                    viewModel.showingTransactionPopup = true
                    print("💰 Showing transaction UI for jar: \(jar.name)")
                }
                
            default:
                print("⚠️ Unknown widget action: \(action)")
            }
        }
    }
}
