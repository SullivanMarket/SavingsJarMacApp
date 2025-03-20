//
//  SavingsDataProvider.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import Foundation
import SwiftUI
import WidgetKit

// Simplified SavingsJar model for widget compatibility
struct SavingsJar: Identifiable {
    let id: UUID
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let color: String
    let icon: String
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
}

// This class handles saving and loading widget data in a shared container
class SavingsDataProvider {
    // Singleton instance
    static let shared = SavingsDataProvider()
    
    // Group ID for App Group to share data between app and widget
    // Make sure this exactly matches what you set up in Xcode capabilities
    private let appGroupID = "group.com.sullivanmarket.savingsjar"
    
    // File name for saving widget data
    private let widgetDataFileName = "widget_data.json"
    
    private init() {}
    
    // Get URL for the shared container
    private func getContainerURL() -> URL? {
        let fileManager = FileManager.default
        
        // Try to get the App Group container
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            print("Successfully accessed App Group container at: \(groupURL.path)")
            return groupURL
        } else {
            // Fallback for development - this won't work for real widgets
            print("Warning: Could not access App Group container. Falling back to Documents directory.")
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
    // Path to the widget data file
    private var widgetDataURL: URL? {
        guard let containerURL = getContainerURL() else {
            print("Error: Could not get container URL")
            return nil
        }
        return containerURL.appendingPathComponent(widgetDataFileName)
    }
    
    // Save data for widgets - call this from your main app
    func saveWidgetData(jars: [SavingsJar], selectedJarID: UUID? = nil) {
        guard let fileURL = widgetDataURL else {
            print("Error: Could not determine widget data file URL")
            return
        }
        
        // Convert the SavingsJar objects to widget jar data
        let widgetJars = jars.map { jar in
            WidgetJarData(
                id: jar.id,
                name: jar.name,
                targetAmount: jar.targetAmount,
                currentAmount: jar.currentAmount,
                color: jar.color,
                icon: jar.icon
            )
        }
        
        // Create widget data
        let widgetData = WidgetData(
            selectedJarID: selectedJarID,
            allJars: widgetJars,
            lastUpdated: Date()
        )
        
        do {
            // Convert to JSON data
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(widgetData)
            
            // Write to file
            try jsonData.write(to: fileURL)
            
            print("Successfully saved widget data to: \(fileURL.path)")
            print("Data size: \(jsonData.count) bytes")
            
            #if canImport(WidgetKit)
            // Refresh widgets - only works in the main app
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        } catch {
            print("Error saving widget data: \(error.localizedDescription)")
        }
    }
    
    // Debug info - helps check if data is being saved correctly
    func printDebugInfo() {
        if let fileURL = widgetDataURL {
            print("Widget data should be at: \(fileURL.path)")
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("Widget data file exists!")
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    print("Widget data file size: \(data.count) bytes")
                    
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("First 200 characters of data: \(String(jsonString.prefix(200)))")
                    }
                } catch {
                    print("Error reading widget data file: \(error.localizedDescription)")
                }
            } else {
                print("Widget data file does not exist yet!")
            }
        }
    }
    
    // Load data for widgets - call this from your widget extension
    func loadWidgetData() -> WidgetData? {
        guard let fileURL = widgetDataURL else {
            print("Error: Could not determine widget data file URL")
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let widgetData = try decoder.decode(WidgetData.self, from: jsonData)
            print("Successfully loaded widget data with \(widgetData.allJars.count) jars")
            return widgetData
        } catch {
            print("Error loading widget data: \(error.localizedDescription)")
            return nil
        }
    }
}

// Simple model for widget data - use this in your widget extension
struct WidgetJarData: Identifiable, Codable {
    let id: UUID
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let color: String
    let icon: String
    
    var percentComplete: Double {
        return min(currentAmount / targetAmount, 1.0)
    }
    
    func getColor() -> Color {
        switch color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

struct WidgetData: Codable {
    let selectedJarID: UUID?
    let allJars: [WidgetJarData]
    let lastUpdated: Date
    
    // Get the selected jar, or the first jar if none is selected
    var selectedJar: WidgetJarData? {
        if let id = selectedJarID {
            return allJars.first(where: { $0.id == id })
        }
        return allJars.first
    }
    
    // Total progress for all jars
    var totalProgress: Double {
        let total = allJars.reduce(0.0) { $0 + $1.targetAmount }
        let current = allJars.reduce(0.0) { $0 + $1.currentAmount }
        return total > 0 ? min(current / total, 1.0) : 0.0
    }
    
    // Total saved amount
    var totalSaved: Double {
        return allJars.reduce(0.0) { $0 + $1.currentAmount }
    }
    
    // Total target amount
    var totalTarget: Double {
        return allJars.reduce(0.0) { $0 + $1.targetAmount }
    }
    
    // Coding keys
    enum CodingKeys: String, CodingKey {
        case selectedJarID, allJars, lastUpdated
    }
    
    // Sample data for previews
    static let sample: WidgetData = {
        return WidgetData(
            selectedJarID: nil,
            allJars: [
                WidgetJarData(id: UUID(), name: "Vacation", targetAmount: 2000, currentAmount: 750, color: "blue", icon: "airplane"),
                WidgetJarData(id: UUID(), name: "New Phone", targetAmount: 1000, currentAmount: 350, color: "purple", icon: "iphone"),
                WidgetJarData(id: UUID(), name: "Emergency Fund", targetAmount: 5000, currentAmount: 2000, color: "red", icon: "heart.circle")
            ],
            lastUpdated: Date()
        )
    }()
}
