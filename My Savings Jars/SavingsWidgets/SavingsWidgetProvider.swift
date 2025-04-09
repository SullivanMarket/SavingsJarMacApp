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
        print("📦 Placeholder called - showing sample")
        return SavingsWidgetEntry(date: Date(), widgetData: WidgetData.sample, eligibleJars: WidgetData.sample.allJars)
    }

    func getSnapshot(in context: Context, completion: @escaping (SavingsWidgetEntry) -> Void) {
        let widgetData = AppGroupFileManager.shared.getWidgetData()
        let eligibleJars = widgetData.allJars.filter { $0.showInWidget }

        let selectedJars: [SavingsJar]
        if context.family == .systemMedium {
            selectedJars = Array(eligibleJars.prefix(2))
        } else if context.family == .systemLarge {
            selectedJars = Array(eligibleJars.prefix(4))
        } else {
            selectedJars = Array(eligibleJars.prefix(1))
        }

        let entry = SavingsWidgetEntry(date: Date(), widgetData: WidgetData(allJars: selectedJars, selectedJar: selectedJars.first), eligibleJars: selectedJars)
        print("📸 Snapshot (\(context.family)) with \(selectedJars.count) jars")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SavingsWidgetEntry>) -> Void) {
        let widgetData = AppGroupFileManager.shared.getWidgetData()
        let eligibleJars = widgetData.allJars.filter { $0.showInWidget }

        var entries: [SavingsWidgetEntry] = []
        let currentDate = Date()

        for i in 0..<eligibleJars.count {
            let jar = eligibleJars[i]
            let entryDate = Calendar.current.date(byAdding: .minute, value: i * 15, to: currentDate)!
            let entryData = WidgetData(allJars: widgetData.allJars, selectedJar: jar)
            let entry = SavingsWidgetEntry(date: entryDate, widgetData: entryData, eligibleJars: eligibleJars)
            entries.append(entry)
        }

        print("📦 Timeline generated with \(entries.count) entries.")
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
