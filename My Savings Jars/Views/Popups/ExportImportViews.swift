//
//  ExportImportViews.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/30/25.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Export Jars View
struct ExportJarsView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool
    @State private var exportSuccess = false
    @State private var exportError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            header(title: "Export Savings Jars")
            content
        }
        .frame(width: 400, height: 350)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }

    private func header(title: String) -> some View {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 45)
            .overlay(
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()
                        .italic()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
            )
    }

    private var content: some View {
        VStack(spacing: 25) {
            Image(systemName: "square.and.arrow.up.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)

            if exportSuccess {
                statusView(title: "Export Successful!", message: "Your savings jars have been exported successfully.", color: .green)
            } else if exportError {
                statusView(title: "Export Failed", message: errorMessage, color: .red)
            } else {
                VStack(spacing: 15) {
                    Text("Export Your Savings Jars").font(.headline)
                    Text("This will create a backup file containing all your savings jars and their data.")
                        .multilineTextAlignment(.center)
                    Text("Total jars to export: \(viewModel.savingsJars.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if exportSuccess || exportError {
                button(title: "Close", color: .blue) {
                    isPresented = false
                }
            } else {
                HStack(spacing: 15) {
                    button(title: "Cancel", color: .red) {
                        isPresented = false
                    }
                    button(title: "Export", color: .blue, disabled: viewModel.savingsJars.isEmpty) {
                        exportJars()
                    }
                }
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
        .padding(.horizontal)
    }

    private func statusView(title: String, message: String, color: Color) -> some View {
        VStack(spacing: 15) {
            Text(title).font(.headline).foregroundColor(color)
            Text(message).multilineTextAlignment(.center)
        }
    }

    private func button(title: String, color: Color, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 120, height: 36)
                .background(RoundedRectangle(cornerRadius: 18).fill(color))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
        .opacity(disabled ? 0.7 : 1.0)
    }

    private func exportJars() {
        do {
            let data = try JSONEncoder().encode(viewModel.savingsJars)
            let panel = NSSavePanel()
            panel.allowedContentTypes = [UTType.json]
            panel.nameFieldStringValue = "SavingsJars_Backup.json"
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                do {
                    try data.write(to: url)
                    DispatchQueue.main.async { exportSuccess = true }
                } catch {
                    DispatchQueue.main.async {
                        exportError = true
                        errorMessage = "Failed to write file: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            exportError = true
            errorMessage = "Failed to encode data: \(error.localizedDescription)"
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

    enum MergeStrategy { case append, replace }

    var body: some View {
        VStack(spacing: 0) {
            header(title: "Import Savings Jars")
            content
        }
        .frame(width: 400, height: 400)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }

    private func header(title: String) -> some View {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 45)
            .overlay(
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()
                        .italic()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
            )
    }

    private var content: some View {
        VStack(spacing: 25) {
            Image(systemName: "square.and.arrow.down.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)

            if importSuccess {
                statusView(title: "Import Successful!", message: "Successfully imported \(importedJarsCount) savings jars.", color: .green)
            } else if importError {
                statusView(title: "Import Failed", message: errorMessage, color: .red)
            } else {
                VStack(spacing: 15) {
                    Text("Import Savings Jars").font(.headline)
                    Text("Select a backup file containing savings jars to import.").multilineTextAlignment(.center)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Import Strategy:").font(.subheadline)
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

            if importSuccess || importError {
                button(title: "Close", color: .blue) {
                    isPresented = false
                }
            } else {
                HStack(spacing: 15) {
                    button(title: "Cancel", color: .red) {
                        isPresented = false
                    }
                    button(title: "Import", color: .blue) {
                        importJars()
                    }
                }
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
        .padding(.horizontal)
    }

    private func statusView(title: String, message: String, color: Color) -> some View {
        VStack(spacing: 15) {
            Text(title).font(.headline).foregroundColor(color)
            Text(message).multilineTextAlignment(.center)
        }
    }

    private func button(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 120, height: 36)
                .background(RoundedRectangle(cornerRadius: 18).fill(color))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func importJars() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.json]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([SavingsJar].self, from: data)
                DispatchQueue.main.async {
                    if mergeStrategy == .replace {
                        viewModel.savingsJars = decoded
                    } else {
                        viewModel.savingsJars.append(contentsOf: decoded)
                    }
                    viewModel.saveDataToUserDefaults()
                    importedJarsCount = decoded.count
                    importSuccess = true
                }
            } catch {
                DispatchQueue.main.async {
                    importError = true
                    errorMessage = "Failed to import: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Helper
extension Picker where Label == Text, SelectionValue: Hashable {
    func horizontalRadioGroupLayout() -> some View {
        self.labelsHidden()
    }
}
