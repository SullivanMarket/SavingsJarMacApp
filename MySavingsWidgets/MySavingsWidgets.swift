//
//  MySavingsWidgets.swift
//  MySavingsWidgets
//
//  Created by Sean Sullivan on 3/27/25.
//

import WidgetKit
import SwiftUI

// MARK: - Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let jars: [WidgetJarData]

    var selectedJar: WidgetJarData? {
        return jars.first
    }
}

// MARK: - Provider
struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        let sampleJars = [
            WidgetJarData(
                id: UUID(),
                name: "Vacation",
                currentAmount: 750,
                targetAmount: 2000,
                color: "blue",
                icon: "airplane",
                progressPercentage: 0.375
            )
        ]
        return SimpleEntry(date: Date(), jars: sampleJars)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let widgetData = AppGroupFileManager.shared.getWidgetData()
        let jars = widgetData.allJars.map {
            WidgetJarData(
                id: $0.id,
                name: $0.name,
                currentAmount: $0.currentAmount,
                targetAmount: $0.targetAmount,
                color: $0.color,
                icon: $0.icon,
                progressPercentage: $0.targetAmount > 0 ? $0.currentAmount / $0.targetAmount : 0.0
            )
        }

        completion(SimpleEntry(date: Date(), jars: jars))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let widgetData = AppGroupFileManager.shared.getWidgetData()
        let jars = widgetData.allJars.map {
            WidgetJarData(
                id: $0.id,
                name: $0.name,
                currentAmount: $0.currentAmount,
                targetAmount: $0.targetAmount,
                color: $0.color,
                icon: $0.icon,
                progressPercentage: $0.targetAmount > 0 ? $0.currentAmount / $0.targetAmount : 0.0
            )
        }

        let entry = SimpleEntry(date: Date(), jars: jars.isEmpty ? createSampleJars() : jars)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func createSampleJars() -> [WidgetJarData] {
        return [
            WidgetJarData(
                id: UUID(),
                name: "Sample Jar",
                currentAmount: 500,
                targetAmount: 1000,
                color: "blue",
                icon: "dollarsign.circle",
                progressPercentage: 0.5
            )
        ]
    }
}

// MARK: - View
struct MySavingsWidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            if let jar = entry.selectedJar {
                SmallSavingsWidgetView(jar: jar)
            } else if entry.jars.isEmpty {
                Text("Loading savings jars...")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("No Jar")
            }

        case .systemMedium:
            if entry.jars.isEmpty {
                Text("Loading savings jars...")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                MediumSavingsWidgetView(jars: entry.jars)
            }

        case .systemLarge:
            if entry.jars.isEmpty {
                Text("Loading savings jars...")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                LargeSavingsWidgetView(jars: entry.jars)
            }

        default:
            Text("Unsupported")
        }
    }
}

// MARK: - Widget
struct MySavingsWidget: Widget {
    let kind: String = "MySavingsWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(macOS 14.0, *) {
                MySavingsWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MySavingsWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Savings Jar")
        .description("View your savings progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Main WidgetBundle
@main
struct MySavingsWidgets: WidgetBundle {
    var body: some Widget {
        MySavingsWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    MySavingsWidget()
} timeline: {
    let jar = WidgetJarData(
        id: UUID(),
        name: "Vacation Fund",
        currentAmount: 750,
        targetAmount: 2000,
        color: "blue",
        icon: "airplane",
        progressPercentage: 0.375
    )
    SimpleEntry(date: Date(), jars: [jar])
}
