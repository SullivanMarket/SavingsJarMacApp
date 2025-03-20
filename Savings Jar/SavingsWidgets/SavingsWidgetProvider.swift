//
//  SavingsWidgetProvider.swift
//  SavingsWidgets
//
//  Created by Sean Sullivan on 3/18/25.
//

import WidgetKit
import SwiftUI

// Define SavingsWidgetEntry first
struct SavingsWidgetEntry: TimelineEntry {
    let date: Date
    let content: WidgetData
}

struct SavingsWidgetProvider: TimelineProvider {
    typealias Entry = SavingsWidgetEntry
    
    func placeholder(in context: Context) -> SavingsWidgetEntry {
        SavingsWidgetEntry(
            date: Date(),
            content: WidgetData.sample
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SavingsWidgetEntry) -> Void) {
        let content = loadWidgetData() ?? WidgetData.sample
        let entry = SavingsWidgetEntry(
            date: Date(),
            content: content
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SavingsWidgetEntry>) -> Void) {
        let content = loadWidgetData() ?? WidgetData.sample
        let entry = SavingsWidgetEntry(
            date: Date(),
            content: content
        )
        
        let timeline = Timeline(
            entries: [entry],
            policy: .atEnd
        )
        completion(timeline)
    }
    
    // Local method to load widget data
    private func loadWidgetData() -> WidgetData? {
        // Use the shared App Group identifier
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.sullivanmarket.savingsjar"
        ) else {
            print("❌ Could not access App Group container")
            return nil
        }
        
        let fileURL = containerURL.appendingPathComponent("widget_data.json")
        
        print("🔍 Attempting to load widget data from: \(fileURL.path)")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("❌ Widget data file does not exist")
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let widgetData = try decoder.decode(WidgetData.self, from: jsonData)
            
            print("✅ Successfully loaded widget data with \(widgetData.allJars.count) jars")
            return widgetData
        } catch {
            print("❌ Error loading widget data: \(error.localizedDescription)")
            return nil
        }
    }
}
