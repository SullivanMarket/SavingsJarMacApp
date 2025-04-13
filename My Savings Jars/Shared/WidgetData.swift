//
//  WidgetData.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

//import Foundation

import Foundation

extension WidgetData {
    static func loadJars() -> [SavingsJar]? {
        let appGroupID = "group.com.yourcompany.mysavingsjars" // <- make sure this matches your App Group ID
        let fileName = "jars.json"

        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(fileName) else {
                print("⚠️ Failed to locate App Group container.")
                return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let jars = try JSONDecoder().decode([SavingsJar].self, from: data)
            return jars
        } catch {
            print("⚠️ Failed to load jars from App Group: \\(error)")
            return nil
        }
    }
}

struct WidgetData: Codable {
    let allJars: [SavingsJar]
    let selectedJar: SavingsJar?

    static let sample = WidgetData(
        allJars: [SavingsJar.sample],
        selectedJar: SavingsJar.sample
    )
}
