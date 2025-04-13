//
//  SavingsDataProvider.swift
//  MySavingsJars
//
//  Created by Sean Sullivan on 3/23/25.
//

import Foundation
import WidgetKit

class SavingsDataProvider {
    static let shared = SavingsDataProvider()

    private let fileName = "savingsJars.json"

    // Load jars from the shared app group container
    func load() -> [SavingsJar] {
        guard let data = AppGroupFileManager.shared.load(from: fileName) else {
            print("📦 No saved jars found in AppGroup container")
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let jars = try decoder.decode([SavingsJar].self, from: data)
            print("✅ Loaded \(jars.count) jars from shared container")
            return jars
        } catch {
            print("❌ Failed to decode jars from shared container: \(error)")
            return []
        }
    }

    // Save jars to the shared app group container
    func save(_ jars: [SavingsJar]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try encoder.encode(jars)
            AppGroupFileManager.shared.save(data: data, to: fileName)
            print("✅ Saved \(jars.count) jars to shared container")
        } catch {
            print("❌ Failed to encode jars: \(error)")
        }
    }
    
    func loadJar(matching id: UUID) -> WidgetJarData? {
        let all = load()
        print("🔍 Looking for jar with ID: \(id.uuidString)")
        
        for jar in all {
            print("   - Available Jar: \(jar.name), ID: \(jar.id.uuidString)")
        }

        if let match = all.first(where: { $0.id == id }) {
            print("✅ Found match: \(match.name)")
            return WidgetJarData(
                id: match.id,
                name: match.name,
                currentAmount: match.currentAmount,
                targetAmount: match.targetAmount,
                color: match.color,
                icon: match.icon,
                progressPercentage: match.targetAmount > 0 ? match.currentAmount / match.targetAmount : 0.0
            )
        } else {
            print("❌ No matching jar found.")
            return nil
        }
    }
}
