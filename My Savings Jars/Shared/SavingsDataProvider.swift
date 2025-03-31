//
//  SavingsDataProvider.swift
//  MySavingsJars
//
//  Created by Sean Sullivan on 3/23/25.
//

import Foundation

class SavingsDataProvider {
    static let shared = SavingsDataProvider()
    
    private let appGroupIdentifier = "group.com.sullivanmarket.savingsjar"

    func getWidgetData() -> WidgetData {
        print("🔄 Loading Widget Data...")

        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            print("❌ ERROR: Widget CANNOT access App Group.")
            return WidgetData(selectedJarID: nil, allJars: [], lastUpdated: Date())
        }

        let savingsJarsFilePath = containerURL.appendingPathComponent("Savings Jar/savingsJars.json")

        guard FileManager.default.fileExists(atPath: savingsJarsFilePath.path) else {
            print("⚠️ No savingsJars.json file found at \(savingsJarsFilePath.path)")
            return WidgetData(selectedJarID: nil, allJars: [], lastUpdated: Date())
        }

        do {
            let data = try Data(contentsOf: savingsJarsFilePath)
            let decoder = JSONDecoder()
            let jars = try decoder.decode([WidgetJarData].self, from: data)

            print("✅ Successfully loaded \(jars.count) jars for the widget.")
            return WidgetData(selectedJarID: nil, allJars: jars, lastUpdated: Date())

        } catch {
            print("❌ ERROR loading widget data: \(error.localizedDescription)")
            return WidgetData(selectedJarID: nil, allJars: [], lastUpdated: Date())
        }
    }
}
