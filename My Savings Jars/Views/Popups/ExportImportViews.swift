//
//  ExportImportViews.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/30/25.
//

import SwiftUI
import UniformTypeIdentifiers // Add this import for UTType

// MARK: - Export Jars View
struct ExportJarsView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool
    @State private var exportSuccess = false
    @State private var exportError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            Rectangle()
                .fill(Color.blue)
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("Export Savings Jars")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                )
            
            // Content
            VStack(spacing: 25) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                
                if exportSuccess {
                    VStack(spacing: 15) {
                        Text("Export Successful!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Your savings jars have been exported successfully.")
                            .multilineTextAlignment(.center)
                    }
                } else if exportError {
                    VStack(spacing: 15) {
                        Text("Export Failed")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("Export Your Savings Jars")
                            .font(.headline)
                        
                        Text("This will create a backup file containing all your savings jars and their data.")
                            .multilineTextAlignment(.center)
                        
                        Text("Total jars to export: \(viewModel.savingsJars.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Buttons
                if exportSuccess || exportError {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Close")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.blue)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    HStack(spacing: 15) {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.red)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            exportJars()
                        } label: {
                            Text("Export")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.blue)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewModel.savingsJars.isEmpty)
                        .opacity(viewModel.savingsJars.isEmpty ? 0.7 : 1.0)
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .padding(.horizontal)
        }
        .frame(width: 400, height: 350)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }
    
    // Export functionality
    private func exportJars() {
        do {
            // Convert jars to JSON data
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(viewModel.savingsJars)
            
            // Create a save panel
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = "SavingsJars_Backup.json"
            savePanel.title = "Export Savings Jars"
            savePanel.allowedContentTypes = [UTType.json]
            savePanel.message = "Choose a location to save your Savings Jars backup"
            
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    do {
                        try data.write(to: url)
                        DispatchQueue.main.async {
                            self.exportSuccess = true
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.exportError = true
                            self.errorMessage = "Failed to write file: \(error.localizedDescription)"
                        }
                    }
                }
            }
        } catch {
            self.exportError = true
            self.errorMessage = "Failed to encode data: \(error.localizedDescription)"
        }
    }
}

// MARK: - Import Jars View
struct ImportJarsView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool
    @State private var importSuccess = false
    @State private var importError = false
    @State private var errorMessage = ""
    @State private var importedJarsCount = 0
    @State private var mergeStrategy = MergeStrategy.append
    
    enum MergeStrategy {
        case append, replace
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            Rectangle()
                .fill(Color.blue)
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("Import Savings Jars")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                )
            
            // Content
            VStack(spacing: 25) {
                Image(systemName: "square.and.arrow.down.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                
                if importSuccess {
                    VStack(spacing: 15) {
                        Text("Import Successful!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Successfully imported \(importedJarsCount) savings jars.")
                            .multilineTextAlignment(.center)
                    }
                } else if importError {
                    VStack(spacing: 15) {
                        Text("Import Failed")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("Import Savings Jars")
                            .font(.headline)
                        
                        Text("Select a backup file containing savings jars to import.")
                            .multilineTextAlignment(.center)
                        
                        // Merge strategy picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Import Strategy:")
                                .font(.subheadline)
                            
                            Picker("", selection: $mergeStrategy) {
                                Text("Add to existing jars").tag(MergeStrategy.append)
                                Text("Replace all existing jars").tag(MergeStrategy.replace)
                            }
                            .pickerStyle(.radioGroup)
                            .horizontalRadioGroupLayout()
                        }
                        .padding(.top, 5)
                    }
                }
                
                Spacer()
                
                // Buttons
                if importSuccess || importError {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Close")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.blue)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    HStack(spacing: 15) {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.red)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            importJars()
                        } label: {
                            Text("Import")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.blue)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .padding(.horizontal)
        }
        .frame(width: 400, height: 400)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }
    
    // Import functionality
    private func importJars() {
        // Create an open panel
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [UTType.json]
        openPanel.title = "Import Savings Jars"
        openPanel.message = "Select a Savings Jars backup file to import"
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.urls.first {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let importedJars = try decoder.decode([SavingsJar].self, from: data)
                    
                    DispatchQueue.main.async {
                        if self.mergeStrategy == .replace {
                            self.viewModel.savingsJars = importedJars
                        } else {
                            self.viewModel.savingsJars.append(contentsOf: importedJars)
                        }
                        
                        self.viewModel.saveDataToUserDefaults()
                        self.importedJarsCount = importedJars.count
                        self.importSuccess = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.importError = true
                        self.errorMessage = "Failed to import: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

// Helper extension for radio group layout
extension Picker where Label == Text, SelectionValue: Hashable {
    func horizontalRadioGroupLayout() -> some View {
        self.labelsHidden()
    }
}
