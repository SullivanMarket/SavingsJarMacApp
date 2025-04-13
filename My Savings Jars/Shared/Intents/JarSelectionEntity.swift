//
//  JarSelectionEntity.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/10/25.
//

import AppIntents
import Foundation

// ✅ Entity representing a single SavingsJar
struct JarSelectionEntity: AppEntity, Identifiable, Hashable {
    var id: UUID { jar.id }
    let jar: SavingsJar

    var jarId: UUID { jar.id }

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Jar"
    static var defaultQuery = JarSelectionQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: jar.name))
    }
}

// ✅ Query to dynamically provide list of jars
struct JarSelectionQuery: EntityQuery {
    func entities(for identifiers: [JarSelectionEntity.ID]) async throws -> [JarSelectionEntity] {
        let all = SavingsDataProvider.shared.load()
        return all
            .filter { identifiers.contains($0.id) }
            .map { JarSelectionEntity(jar: $0) }
    }

    func suggestedEntities() async throws -> [JarSelectionEntity] {
        let all = SavingsDataProvider.shared.load()
        return all.map { JarSelectionEntity(jar: $0) }
    }

    func defaultResult() async -> JarSelectionEntity? {
        guard let first = SavingsDataProvider.shared.load().first else { return nil }
        return JarSelectionEntity(jar: first)
    }
}
