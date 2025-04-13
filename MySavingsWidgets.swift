//
//  MySavingsWidgets.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import WidgetKit
import SwiftUI
import Foundation

// MARK: - Widget View
struct MySavingsWidgetsEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: SavingsWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            if let jar = entry.jars.first {
                SmallSavingsWidgetView(jar: jar, timestamp: entry.timestamp)            } else {
                Text("No Jar Selected")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.secondary)
            }

        case .systemMedium:
            if !entry.jars.isEmpty {
                MediumSavingsWidgetView(jars: entry.jars, timestamp: entry.timestamp)
            } else {
                Text("No Jars Selected")
            }

        case .systemLarge:
            if !entry.jars.isEmpty {
                LargeSavingsWidgetView(jars: entry.jars, timestamp: entry.timestamp)
            } else {
                Text("No Jars Selected")
            }

        default:
            Text("Unsupported Widget Size")
        }
    }
}

// MARK: - Widget
@main
struct MySavingsWidgets: Widget {
    let kind: String = "MySavingsWidgets_v2a"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectJarIntent.self,
            provider: SavingsWidgetProvider()
        ) { entry in
            if #available(macOS 14.0, *) {
                MySavingsWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MySavingsWidgetsEntryView(entry: entry)
                    .padding()
                    .background(Color(.windowBackgroundColor))
            }
        }
        .configurationDisplayName("Savings Jar")
        .description("Track savings for a specific jar.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    MySavingsWidgets()
} timeline: {
    SavingsWidgetEntry(
        date: Date(),
        jar: nil,
        jars: [],
        timestamp: Date()
    )
}
