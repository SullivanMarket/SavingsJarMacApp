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
                    settingsManager.applyAppearanceSettings()
                    viewModel.loadDataFromUserDefaults()
                    print("🔄 App launched with \(viewModel.savingsJars.count) jars")
                }
                .onOpenURL { url in
                    processWidgetLaunch(url: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowAddJarPopup"))) { _ in
                    viewModel.editingJar = nil
                    viewModel.isEditingJar = false
                    viewModel.showingAddJarPopup = true
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowImportPopup"))) { _ in
                    viewModel.triggerImport = true
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowExportPopup"))) { _ in
                    viewModel.triggerExport = true
                }
        }
        .windowStyle(.hiddenTitleBar)
        .onChange(of: scenePhase, initial: false) { oldPhase, newPhase in
            print("🔄 Scene changed from \(oldPhase) → \(newPhase)")

            if newPhase == .background {
                print("💾 App entering background - saving data")
                viewModel.saveDataToUserDefaults()
            } else if newPhase == .active {
                print("🔄 App becoming active - reloading data")
                viewModel.loadDataFromUserDefaults()
            }
        }
        #if os(macOS)
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Add Jar") {
                    NotificationCenter.default.post(name: Notification.Name("ShowAddJarPopup"), object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button("Import Jars") {
                    NotificationCenter.default.post(name: Notification.Name("ShowImportPopup"), object: nil)
                }

                Button("Export Jars") {
                    NotificationCenter.default.post(name: Notification.Name("ShowExportPopup"), object: nil)
                }

                Divider()

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

    private func processWidgetLaunch(url: URL) {
        print("📱 App launched from widget with URL: \(url)")

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let action = components.host {

            switch action {
            case "viewJar":
                if let jarIdParam = components.queryItems?.first(where: { $0.name == "id" })?.value,
                   let jarId = UUID(uuidString: jarIdParam),
                   let _ = viewModel.savingsJars.firstIndex(where: { $0.id == jarId }) {
                    print("🔍 Selected jar from widget: \(jarId)")
                }

            case "addTransaction":
                if let jarIdParam = components.queryItems?.first(where: { $0.name == "id" })?.value,
                   let jarId = UUID(uuidString: jarIdParam),
                   let jar = viewModel.savingsJars.first(where: { $0.id == jarId }) {
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
