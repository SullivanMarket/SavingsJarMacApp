//
//  SavingsViewModel.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
import Combine

// Define a feature flag to enable/disable widget functionality
// This can be defined in your build settings
#if DEBUG
// For development, we'll disable widgets until properly configured
let WIDGETS_ENABLED = true
#else
let WIDGETS_ENABLED = true
#endif

// Import WidgetKit conditionally only if widgets are enabled
#if WIDGETS_ENABLED
import WidgetKit
#endif

class SavingsViewModel: ObservableObject {
    @Published var savingsJars: [SavingsJar] = []
    @Published var selectedJarForTransaction: SavingsJar?
    @Published var showingTransactionPopup = false
    @Published var selectedWidgetJarId: UUID?
    
    // Settings-related properties
    let formatter = CurrencyFormatter.shared
    private var settingsCancellable: AnyCancellable?
    
    init() {
        loadSavingsJars()
    }
    
    // Call this method from the ContentView to connect to settings
    func configureWithSettings(_ settingsManager: SettingsManager) {
        // Configure the formatter to use settings
        formatter.configure(with: settingsManager)
        
        // Observe changes to settings to update UI accordingly
        settingsCancellable = settingsManager.$settings
            .sink { [weak self] _ in
                // Refresh the UI when settings change
                self?.objectWillChange.send()
            }
    }
    
    func addSavingsJar(_ jar: SavingsJar) {
        savingsJars.append(jar)
        saveSavingsJars()
        
        #if WIDGETS_ENABLED
        updateWidgetData()
        #endif
    }
    
    // Create a new jar with default settings
    func createNewJarWithDefaults(settingsManager: SettingsManager, name: String) -> SavingsJar {
        let settings = settingsManager.settings
        return SavingsJar(
            name: name,
            targetAmount: settings.defaultTarget,
            currentAmount: 0,
            color: settings.defaultColor,
            icon: "banknote.fill"
        )
    }
    
    func saveSavingsJars() {
        let csvString = savingsJarsToCSV()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("savingsJars.csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing to CSV file: \(error)")
        }
    }
    
    func savingsJarsToCSV() -> String {
        var csvString = "id,name,targetAmount,currentAmount,color,icon,creationDate,transactions\n"
        
        for jar in savingsJars {
            let creationDateString = ISO8601DateFormatter().string(from: jar.creationDate)
            
            // Convert transactions to a readable CSV-friendly format
            let transactionsString = jar.transactions.map { transaction in
                let dateString = ISO8601DateFormatter().string(from: transaction.date)
                return "\(transaction.amount)|\(dateString)"
            }.joined(separator: ";")
            
            let escapedName = jar.name.replacingOccurrences(of: ",", with: "_")
            
            let row = "\(jar.id),\(escapedName),\(jar.targetAmount),\(jar.currentAmount),\(jar.color),\(jar.icon),\(creationDateString),\(transactionsString)\n"
            csvString.append(row)
        }
        
        return csvString
    }

    func loadSavingsJars() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("savingsJars.csv")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let csvString = try String(contentsOf: fileURL, encoding: .utf8)
                let lines = csvString.components(separatedBy: .newlines)
                
                var loadedJars: [SavingsJar] = []
                
                for line in lines.dropFirst() {
                    let values = line.components(separatedBy: ",")
                    if values.count == 8 {
                        let id = UUID(uuidString: values[0]) ?? UUID()
                        let name = values[1]
                        let targetAmount = Double(values[2]) ?? 0
                        let currentAmount = Double(values[3]) ?? 0
                        let color = values[4]
                        let icon = values[5]
                        let creationDate = ISO8601DateFormatter().date(from: values[6]) ?? Date()
                        
                        // Decode transactions using the Transaction type alias
                        var transactions: [Transaction] = []
                        let transactionsString = values[7]
                        if !transactionsString.isEmpty {
                            let transactionStrings = transactionsString.components(separatedBy: ";")
                            transactions = transactionStrings.compactMap { transactionString in
                                let parts = transactionString.components(separatedBy: "|")
                                guard parts.count == 2,
                                      let amount = Double(parts[0]),
                                      let date = ISO8601DateFormatter().date(from: parts[1]) else {
                                    return nil
                                }
                                // Use explicit namespaced type to avoid ambiguity
                                return Transaction(amount: amount, date: date)
                            }
                        }
                        
                        let jar = SavingsJar(
                            id: id,
                            name: name,
                            targetAmount: targetAmount,
                            currentAmount: currentAmount,
                            color: color,
                            icon: icon,
                            creationDate: creationDate,
                            transactions: transactions
                        )
                        loadedJars.append(jar)
                    }
                }
                
                self.savingsJars = loadedJars
                
                #if WIDGETS_ENABLED
                // After loading, update the widget data
                updateWidgetData()
                #endif
                
            } catch {
                print("Error loading savings jars from CSV: \(error)")
                loadSampleData()
            }
        } else {
            print("Savings jars CSV file not found. Loading sample data.")
            loadSampleData()
        }
    }

    func loadSampleData() {
        let sampleTransactions1 = [
            Transaction(amount: 100, date: Date().addingTimeInterval(-86400 * 5)),
            Transaction(amount: -25, date: Date().addingTimeInterval(-86400 * 3)),
            Transaction(amount: 50, date: Date().addingTimeInterval(-86400 * 1))
        ]
        
        let sampleTransactions2 = [
            Transaction(amount: 150, date: Date().addingTimeInterval(-86400 * 7)),
            Transaction(amount: 50, date: Date().addingTimeInterval(-86400 * 4)),
            Transaction(amount: -30, date: Date().addingTimeInterval(-86400 * 2))
        ]
        
        let sampleTransactions3 = [
            Transaction(amount: 500, date: Date().addingTimeInterval(-86400 * 10)),
            Transaction(amount: 200, date: Date().addingTimeInterval(-86400 * 6)),
            Transaction(amount: -100, date: Date().addingTimeInterval(-86400 * 3))
        ]
        
        self.savingsJars = [
            SavingsJar(name: "Vacation", targetAmount: 2000, currentAmount: 750, color: "blue", icon: "airplane", transactions: sampleTransactions1),
            SavingsJar(name: "New Phone", targetAmount: 1000, currentAmount: 350, color: "purple", icon: "iphone", transactions: sampleTransactions2),
            SavingsJar(name: "Emergency Fund", targetAmount: 5000, currentAmount: 2000, color: "red", icon: "heart.circle", transactions: sampleTransactions3)
        ]
        
        #if WIDGETS_ENABLED
        // Update widget data with sample data
        updateWidgetData()
        #endif
    }
    
    func updateSavingsJar(id: UUID, amount: Double) {
        if let index = savingsJars.firstIndex(where: { $0.id == id }) {
            // Add the transaction - using explicit Transaction type to avoid ambiguity
            let transaction = Transaction(amount: amount, date: Date())
            savingsJars[index].transactions.append(transaction)
            
            // Limit to last 10 transactions
            if savingsJars[index].transactions.count > 10 {
                savingsJars[index].transactions.removeFirst(
                    savingsJars[index].transactions.count - 10
                )
            }
            
            // Update the balance
            savingsJars[index].currentAmount += amount
            
            saveSavingsJars()
            
            #if WIDGETS_ENABLED
            updateWidgetData()
            #endif
        }
    }
    
    func deleteSavingsJar(at indexSet: IndexSet) {
        savingsJars.remove(atOffsets: indexSet)
        saveSavingsJars()
        
        #if WIDGETS_ENABLED
        updateWidgetData()
        #endif
    }
    
    func deleteSavingsJar(with id: UUID) {
        if let index = savingsJars.firstIndex(where: { $0.id == id }) {
            #if WIDGETS_ENABLED
            // If we're deleting the jar that's selected for the widget,
            // reset the selection
            if selectedWidgetJarId == id {
                selectedWidgetJarId = nil
            }
            #endif
            
            savingsJars.remove(at: index)
            saveSavingsJars()
            
            #if WIDGETS_ENABLED
            updateWidgetData()
            #endif
        }
    }
    
    func getColorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    func showTransactionFor(jar: SavingsJar) {
        selectedJarForTransaction = jar
        showingTransactionPopup = true
    }
    
    // MARK: - Widget Integration
    
    #if WIDGETS_ENABLED
    // Update widget data whenever something changes
    func updateWidgetData() {
        // Save the actual data through SavingsDataProvider
        SavingsDataProvider.shared.saveWidgetData(
            jars: savingsJars,
            selectedJarID: selectedWidgetJarId
        )
        
        // Also print debug info to verify data is being saved
        SavingsDataProvider.shared.printDebugInfo()
        
        print("Widget data updated")
    }
    
    // Select a jar to feature in the widget
    func selectJarForWidget(_ jar: SavingsJar) {
        selectedWidgetJarId = jar.id
        updateWidgetData()
    }
    
    // Clear the widget jar selection
    func clearWidgetJarSelection() {
        selectedWidgetJarId = nil
        updateWidgetData()
    }
    
    // Check if a jar is selected for the widget
    func isSelectedForWidget(_ jar: SavingsJar) -> Bool {
        return selectedWidgetJarId == jar.id
    }
    #else
    // Stub implementations for when widgets are disabled
    
    // These methods do nothing but are available to avoid compile errors
    func updateWidgetData() {
        // Do nothing
    }
    
    func selectJarForWidget(_ jar: SavingsJar) {
        selectedWidgetJarId = jar.id
        // Widget functionality disabled
    }
    
    func clearWidgetJarSelection() {
        selectedWidgetJarId = nil
        // Widget functionality disabled
    }
    
    func isSelectedForWidget(_ jar: SavingsJar) -> Bool {
        return selectedWidgetJarId == jar.id
    }
    #endif
    
    // MARK: - Export and Import Methods
    func exportJars(to url: URL) {
        let csvString = savingsJarsToCSV()
        do {
            try csvString.write(to: url, atomically: true, encoding: .utf8)
            print("Jars exported successfully to \(url.path)")
        } catch {
            print("Error exporting jars: \(error)")
        }
    }
    
    func importJars(from url: URL) throws {
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let lines = csvString.components(separatedBy: .newlines)
            
            // Validate the CSV has a header and at least one data row
            guard lines.count > 1, lines[0].contains("id,name,targetAmount") else {
                print("Invalid CSV format")
                throw NSError(domain: "ImportError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid CSV format"])
            }
            
            var loadedJars: [SavingsJar] = []
            
            // Skip the header row
            for line in lines.dropFirst() {
                // Trim any whitespace
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip empty lines
                guard !trimmedLine.isEmpty else { continue }
                
                let values = line.components(separatedBy: ",")
                
                // Ensure we have enough values
                guard values.count >= 7 else {
                    print("Skipping invalid line: \(line)")
                    continue
                }
                
                do {
                    let id = UUID(uuidString: values[0]) ?? UUID()
                    let name = values[1]
                    let targetAmount = Double(values[2]) ?? 0
                    let currentAmount = Double(values[3]) ?? 0
                    let color = values[4]
                    let icon = values[5]
                    let creationDate = ISO8601DateFormatter().date(from: values[6]) ?? Date()
                    
                    // Decode transactions if available - using explicit Transaction type
                    var transactions: [Transaction] = []
                    if values.count == 8 && !values[7].isEmpty {
                        let transactionsString = values[7]
                        let transactionStrings = transactionsString.components(separatedBy: ";")
                        transactions = transactionStrings.compactMap { transactionString in
                            let parts = transactionString.components(separatedBy: "|")
                            guard parts.count == 2,
                                  let amount = Double(parts[0]),
                                  let date = ISO8601DateFormatter().date(from: parts[1]) else {
                                return nil
                            }
                            return Transaction(amount: amount, date: date)
                        }
                    }
                    
                    let jar = SavingsJar(
                        id: id,
                        name: name,
                        targetAmount: targetAmount,
                        currentAmount: currentAmount,
                        color: color,
                        icon: icon,
                        creationDate: creationDate,
                        transactions: transactions
                    )
                    loadedJars.append(jar)
                }
            }
            
            // Only replace jars if we successfully loaded some
            guard !loadedJars.isEmpty else {
                print("No valid jars found in the import file")
                throw NSError(domain: "ImportError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No valid jars found"])
            }
            
            // Replace existing jars with imported jars
            self.savingsJars = loadedJars
            
            // Save the imported jars to the default location
            saveSavingsJars()
            
            #if WIDGETS_ENABLED
            // Update widget data
            updateWidgetData()
            #endif
            
            print("Successfully imported \(loadedJars.count) jars")
        } catch {
            print("Error importing jars: \(error)")
            throw error
        }
    }
}
