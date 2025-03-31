//
//  SavingsViewModel.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/23/25.
//

// Location: My Savings Jars/ViewModels/SavingsViewModel.swift
import Foundation
import SwiftUI
import Combine

class SavingsViewModel: ObservableObject {
    @Published var savingsJars: [SavingsJar] = []
    @Published var selectedJarId: UUID?
    @Published var selectedJarForTransaction: SavingsJar?
    @Published var showingTransactionPopup: Bool = false
    //@Published var selectedWidgetJarId: UUID? = nil
    
    @Published var selectedWidgetJarId: UUID? = nil
    @Published var selectedJarForEditing: SavingsJar?
    @Published var showingEditJarPopup: Bool = false
    @Published var debugMessage: String = ""
    
    // Method to add a transaction to a specific jar
    func addSavingsTransaction(to jar: SavingsJar, transaction: Transaction) {
        guard let index = savingsJars.firstIndex(where: { $0.id == jar.id }) else {
            print("❌ Jar not found for transaction")
            return
        }
        
        savingsJars[index].currentAmount += transaction.amount
        savingsJars[index].transactions.append(transaction)
        saveDataToUserDefaults()
    }
    
    // Method to update a savings jar
    func updateSavingsJar(updatedJar: SavingsJar) {
        if let index = savingsJars.firstIndex(where: { $0.id == updatedJar.id }) {
            savingsJars[index] = updatedJar
            saveDataToUserDefaults()
        } else {
            print("❌ Jar not found for update")
        }
    }
    
    // Method to delete a savings jar
    func deleteSavingsJar(at indexSet: IndexSet) {
        savingsJars.remove(atOffsets: indexSet)
        saveDataToUserDefaults()
    }
    
    // Save data to UserDefaults
    func saveDataToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let jarData = try encoder.encode(savingsJars)
            UserDefaults.standard.set(jarData, forKey: "SavingsJars_Data")
        } catch {
            print("❌ Failed to encode jars: \(error)")
        }
    }
    
    // Load data from UserDefaults
    func loadDataFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: "SavingsJars_Data") else {
            print("⚠️ No jar data found")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            savingsJars = try decoder.decode([SavingsJar].self, from: data)
        } catch {
            print("❌ Failed to decode jars: \(error)")
        }
    }
    
    // Initialize with some default data if needed
    init() {
        loadDataFromUserDefaults()
        
        if savingsJars.isEmpty {
            let sampleJar = SavingsJar(
                name: "My First Jar",
                targetAmount: 1000,
                currentAmount: 0,
                color: "blue",
                icon: "dollarsign.circle"
            )
            savingsJars.append(sampleJar)
            saveDataToUserDefaults()
        }
    }
}
