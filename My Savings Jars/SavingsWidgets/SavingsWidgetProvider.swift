//
//  SavingsWidgetProvider.swift
//  MySavingsWidgetsExtension
//
//  Created by Sean Sullivan on 3/23/25.
//

import WidgetKit
import SwiftUI
import Foundation

struct SavingsWidgetProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> SavingsWidgetEntry {
        return SavingsWidgetEntry(date: Date(), widgetData: WidgetData.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SavingsWidgetEntry) -> Void) {
        let widgetData = SavingsDataProvider.shared.getWidgetData()
        let entry = SavingsWidgetEntry(date: Date(), widgetData: widgetData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SavingsWidgetEntry>) -> Void) {
        let widgetData = SavingsDataProvider.shared.getWidgetData()
        let entry = SavingsWidgetEntry(date: Date(), widgetData: widgetData)

        print("📦 Widget Timeline Loaded. Total Jars: \(widgetData.allJars.count)")

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Configuration
struct SavingsJarWidget: Widget {
    let kind: String = "SavingsJarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SavingsWidgetProvider()) { entry in
            SavingsWidgetView(entry: entry) // ✅ FIXED: Pass entry instead of separate variables
        }
        .configurationDisplayName("Savings Jars")
        .description("View your savings progress directly on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Preview
struct SavingsJarWidget_Previews: PreviewProvider {
    static var previews: some View {
        SavingsWidgetView(
            entry: SavingsWidgetEntry(date: Date(), widgetData: WidgetData.sample)
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// MARK: - Force Widget Update
func forceWidgetUpdate() {
    #if canImport(WidgetKit)
    WidgetCenter.shared.reloadAllTimelines()
    print("🔄 Widget timelines reloaded.")
    #endif
}
