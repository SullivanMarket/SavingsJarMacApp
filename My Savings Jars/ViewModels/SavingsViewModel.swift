//
//  SavingsViewModel.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/1/25.
//

import Foundation
import SwiftUI
import Combine

class SavingsViewModel: ObservableObject {
    @Published var savingsJars: [SavingsJar] = []
    @Published var selectedJarForEditing: SavingsJar?
    @Published var selectedJarForTransaction: SavingsJar?
    @Published var showingTransactionPopup: Bool = false
    
    // Add inside class SavingsViewModel
    @Published var editingJar: SavingsJar? = nil
    @Published var isEditingJar: Bool = false
    @Published var showingAddJarPopup: Bool = false
    @Published var triggerImport: Bool = false
    @Published var triggerExport: Bool = false

    private let jarsFile = "savingsJars.json"

    init() {
        loadJars()
    }

    func addSavingsJar(_ jar: SavingsJar) {
        savingsJars.append(jar)
        saveJars()
        SavingsDataProvider.shared.save(savingsJars)
    }

    func updateSavingsJar(updatedJar: SavingsJar) {
        if let index = savingsJars.firstIndex(where: { $0.id == updatedJar.id }) {
            savingsJars[index] = updatedJar
            saveJars()
            SavingsDataProvider.shared.save(savingsJars)
        }
    }

    func deleteSavingsJar(at offsets: IndexSet) {
        savingsJars.remove(atOffsets: offsets)
        saveJars()
        SavingsDataProvider.shared.save(savingsJars)
    }

    func addSavingsTransaction(jar: SavingsJar, amount: Double, note: String, isDeposit: Bool) {
        var updatedJar = jar
        let signedAmount = isDeposit ? amount : -amount

        let transaction = SavingsTransaction(id: UUID(), date: Date(), amount: signedAmount, note: note)
        updatedJar.transactions.insert(transaction, at: 0)
        updatedJar.currentAmount += signedAmount

        updateSavingsJar(updatedJar: updatedJar)
    }

    // MARK: - Persistence

    func saveJars() {
        if let data = try? JSONEncoder().encode(savingsJars) {
            AppGroupFileManager.shared.save(data: data, to: jarsFile)
            UserDefaults.standard.set(data, forKey: "SavingsJars")
            AppGroupFileManager.shared.forceWidgetUpdate()
            print("✅ Saved \(savingsJars.count) jars to App Group + UserDefaults")
        }
    }

    func loadJars() {
        if let data = AppGroupFileManager.shared.load(from: jarsFile),
           let decoded = try? JSONDecoder().decode([SavingsJar].self, from: data) {
            self.savingsJars = decoded
            print("📥 Loaded \(decoded.count) jars from App Group")
        } else if let data = UserDefaults.standard.data(forKey: "SavingsJars"),
                  let jars = try? JSONDecoder().decode([SavingsJar].self, from: data) {
            self.savingsJars = jars
            print("📥 Fallback: Loaded jars from UserDefaults")
        } else {
            print("⚠️ Failed to load jars from all sources")
        }
    }

    // MARK: - Export/Import

    func exportJars() -> Data? {
        return try? JSONEncoder().encode(savingsJars)
    }

    func importJars(from data: Data) {
        guard let imported = try? JSONDecoder().decode([SavingsJar].self, from: data) else {
            print("❌ Failed to import jars.")
            return
        }

        self.savingsJars = imported
        saveJars()
    }

    // MARK: - Legacy Support

    func saveDataToUserDefaults() {
        if let data = try? JSONEncoder().encode(savingsJars) {
            UserDefaults.standard.set(data, forKey: "SavingsJars")
            print("✅ Saved jars to UserDefaults")
        }
    }

    func loadDataFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "SavingsJars"),
           let jars = try? JSONDecoder().decode([SavingsJar].self, from: data) {
            self.savingsJars = jars
            print("📥 Loaded jars from UserDefaults")
        }
    }
}
