//
//  WidgetData.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

import Foundation

struct WidgetData: Codable {
    let allJars: [SavingsJar]
    let selectedJar: SavingsJar?

    static let sample = WidgetData(
        allJars: [SavingsJar.sample],
        selectedJar: SavingsJar.sample
    )
}
