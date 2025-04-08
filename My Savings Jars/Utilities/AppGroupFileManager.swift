//
//  AppGroupFileManager.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

import Foundation
import WidgetKit

class AppGroupFileManager {
    static let shared = AppGroupFileManager()

    private init() {}

    private let containerURL: URL = {
        let groupIdentifier = "group.com.sullivanmarket.savingsjar"
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
            fatalError("App Group container not found")
        }
        return url
    }()

    func save(data: Data, to filename: String) {
        let url = containerURL.appendingPathComponent(filename)
        try? data.write(to: url)
    }

    func load(from filename: String) -> Data? {
        let url = containerURL.appendingPathComponent(filename)
        return try? Data(contentsOf: url)
    }

    func forceWidgetUpdate() {
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 Widget timelines reloaded.")
    }
}

// MARK: - Widget-Specific Helper
extension AppGroupFileManager {
    func getWidgetData() -> WidgetData {
        let allJars = SavingsDataProvider.shared.load()
        let selected = allJars.filter { $0.showInWidget }.randomElement()
        print("📦 getWidgetData() found \(allJars.count) jars, \(allJars.filter { $0.showInWidget }.count) marked for widget")
        return WidgetData(allJars: allJars, selectedJar: selected)
    }
}
