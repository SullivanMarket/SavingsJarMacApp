//
//  AppGroupFileManager.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/27/25.
//

import Foundation

class AppGroupFileManager {
    // Singleton instance
    static let shared = AppGroupFileManager()
    
    // MARK: - Properties
    
    // App group identifier - CORRECTED to match entitlements
    private let appGroupIdentifier = "group.com.sullivanmarket.savingsjar"
    
    // File names
    private let savingsJarsFileName = "savingsJars.json"
    private let selectedJarFileName = "selectedJar.json"
    
    // Full paths
    private var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    private var savingsJarsURL: URL? {
        guard let containerURL = containerURL else { return nil }
        let directory = containerURL.appendingPathComponent("Savings Jar")
        return directory.appendingPathComponent(savingsJarsFileName)
    }
    
    private var selectedJarURL: URL? {
        guard let containerURL = containerURL else { return nil }
        let directory = containerURL.appendingPathComponent("Savings Jar")
        return directory.appendingPathComponent(selectedJarFileName)
    }
    
    // MARK: - Initialization
    
    private init() {
        // Create directory if needed
        createDirectoryIfNeeded()
    }
    
    // MARK: - Directory Management
    
    private func createDirectoryIfNeeded() {
        guard let containerURL = containerURL else {
            print("❌ Failed to get app group container URL. Check entitlements for: \(appGroupIdentifier)")
            return
        }
        
        let directoryURL = containerURL.appendingPathComponent("Savings Jar")
        
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("✅ Created or confirmed app group directory at: \(directoryURL.path)")
        } catch {
            print("❌ Failed to create directory in app group container: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Diagnostics
    
    func diagnoseAppGroupAccess() {
        print("🔍 DIAGNOSING APP GROUP ACCESS")
        
        // 1. Check if we can get the container URL
        guard let containerURL = containerURL else {
            print("❌ Failed to get app group container URL. Check entitlements for: \(appGroupIdentifier)")
            return
        }
        
        print("✅ App Group container URL found: \(containerURL.absoluteString)")
        
        // 2. Check if we can create a file in the container
        let testFileURL = containerURL.appendingPathComponent("test.txt")
        do {
            try "Test data".write(to: testFileURL, atomically: true, encoding: .utf8)
            print("✅ Successfully wrote to App Group container")
            
            // Clean up
            try FileManager.default.removeItem(at: testFileURL)
            print("✅ Successfully removed test file")
        } catch {
            print("❌ Failed to write to App Group container: \(error)")
        }
        
        // 3. Create our directory
        createDirectoryIfNeeded()
        
        // 4. Check if our files exist
        if let savingsJarsURL = savingsJarsURL,
           FileManager.default.fileExists(atPath: savingsJarsURL.path) {
            print("✅ Savings jars file exists at: \(savingsJarsURL.path)")
        } else if let url = savingsJarsURL {
            print("⚠️ Savings jars file does not exist at: \(url.path)")
        }
        
        if let selectedJarURL = selectedJarURL,
           FileManager.default.fileExists(atPath: selectedJarURL.path) {
            print("✅ Selected jar file exists at: \(selectedJarURL.path)")
        } else if let url = selectedJarURL {
            print("⚠️ Selected jar file does not exist at: \(url.path)")
        }
    }
    
    // MARK: - File Operations
    
    func save(_ jars: [SavingsJar]) {
        createDirectoryIfNeeded()
        
        guard let savingsJarsURL = savingsJarsURL else {
            print("❌ Failed to get savingsJarsURL path")
            return
        }
        
        do {
            // Convert to PublicSavingsJar format for storage
            let publicJars = jars.map { jar -> PublicSavingsJar in
                return PublicSavingsJar(
                    id: jar.id,
                    name: jar.name,
                    targetAmount: jar.targetAmount,
                    currentAmount: jar.currentAmount,
                    color: jar.color,
                    icon: jar.icon,
                    creationDate: jar.creationDate
                )
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(publicJars)
            try data.write(to: savingsJarsURL)
            print("✅ Successfully saved \(publicJars.count) jars to app group container")
        } catch {
            print("❌ Failed to save data to App Group container: \(error)")
        }
    }
    
    func load() -> [SavingsJar]? {
        guard let savingsJarsURL = savingsJarsURL,
              FileManager.default.fileExists(atPath: savingsJarsURL.path) else {
            print("⚠️ No data found in App Group container or error: \(savingsJarsURL?.path ?? "unknown path")")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: savingsJarsURL)
            print("✅ Successfully loaded \(data.count) bytes from App Group container")
            
            let decoder = JSONDecoder()
            
            // First try to decode as PublicSavingsJar (widget format)
            let publicJars = try decoder.decode([PublicSavingsJar].self, from: data)
            
            // Convert back to SavingsJar format for the app
            let fullJars = publicJars.map { publicJar -> SavingsJar in
                return SavingsJar(
                    id: publicJar.id,
                    name: publicJar.name,
                    targetAmount: publicJar.targetAmount,
                    currentAmount: publicJar.currentAmount,
                    color: publicJar.color,
                    icon: publicJar.icon,
                    creationDate: publicJar.creationDate,
                    transactions: [] // Initialize with empty transactions
                )
            }
            
            print("✅ Successfully decoded \(fullJars.count) jars from app group container")
            return fullJars
        } catch {
            print("❌ Failed to decode jars from App Group container: \(error)")
            return nil
        }
    }
    
    func saveSelectedJarID(_ jarID: UUID) {
        createDirectoryIfNeeded()
        
        guard let selectedJarURL = selectedJarURL else {
            print("❌ Failed to get selectedJarURL path")
            return
        }
        
        do {
            let idWrapper = ["selectedJarID": jarID.uuidString]
            let data = try JSONEncoder().encode(idWrapper)
            try data.write(to: selectedJarURL)
            print("✅ Successfully saved selected jar ID to app group container")
        } catch {
            print("❌ Failed to save selected jar ID to App Group container: \(error)")
        }
    }
    
    func loadSelectedJarID() -> UUID? {
        guard let selectedJarURL = selectedJarURL,
              FileManager.default.fileExists(atPath: selectedJarURL.path) else {
            print("⚠️ No selected jar ID found in App Group container")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: selectedJarURL)
            let idWrapper = try JSONDecoder().decode([String: String].self, from: data)
            
            if let idString = idWrapper["selectedJarID"], let uuid = UUID(uuidString: idString) {
                print("✅ Successfully loaded selected jar ID from app group container")
                return uuid
            } else {
                print("❌ Invalid selected jar ID format")
                return nil
            }
        } catch {
            print("❌ Failed to load selected jar ID from App Group container: \(error)")
            return nil
        }
    }
}
