//
//  ContentView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/17/25.
//

import SwiftUI
import Foundation
#if WIDGETS_ENABLED
import WidgetKit
#endif
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @StateObject private var viewModel = SavingsViewModel()
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingAddJar = false
    @State private var showingSettings = false
    @State private var showingWidgetConfig = false
    @State private var selectedJarId: UUID?
    
    private func showAboutView() {
        #if os(macOS)
        // Use NSPanel instead of NSWindow for better behavior
        let aboutPanel = NSPanel(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 250),
            styleMask: [.titled, .closable, .miniaturizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        aboutPanel.title = "About Savings Jar"
        aboutPanel.isFloatingPanel = true
        
        // Get the version from the bundle
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0"
        
        // Create a weak reference to avoid retain cycles
        weak var weakPanel = aboutPanel
        
        aboutPanel.contentView = NSHostingView(rootView:
            VStack(spacing: 15) {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("Savings Jar")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("© 2025 Sullivan Market LLC")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Manage and track your savings goals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                // Add a close button
                Button("Close") {
                    weakPanel?.close()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(width: 400, height: 250)
            .padding()
        )
        
        aboutPanel.center()
        aboutPanel.makeKeyAndOrderFront(nil)
        #endif
    }
    
    private func exportJarsAction() {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "savings_jars.csv"
        
        if savePanel.runModal() == .OK {
            if let url = savePanel.url {
                viewModel.exportJars(to: url)
            }
        }
        #endif
    }
    
    #if WIDGETS_ENABLED
    func selectJarForWidget(_ jar: SavingsJar) {
        let widgetJar = WidgetJarData(
            id: jar.id,
            name: jar.name,
            targetAmount: jar.targetAmount,
            currentAmount: jar.currentAmount,
            color: jar.color,
            icon: jar.icon
        )
        
        let userDefaults = UserDefaults(suiteName: "group.com.sullivanmarket.savingsjar")
        userDefaults?.set(widgetJar.id.uuidString, forKey: "SelectedWidgetJarID")
        
        // Reload widget
        WidgetCenter.shared.reloadAllTimelines()
    }
    #endif

    private func importJarsAction() {
        #if os(macOS)
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.commaSeparatedText]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                do {
                    try viewModel.importJars(from: url)
                    // Show success alert
                    let alert = NSAlert()
                    alert.messageText = "Import Successful"
                    alert.informativeText = "Your savings jars have been imported."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                } catch {
                    // Show error alert
                    let alert = NSAlert()
                    alert.messageText = "Import Failed"
                    alert.informativeText = "There was an error importing your savings jars. \(error.localizedDescription)"
                    alert.alertStyle = .critical
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
        #endif
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedJarId) {
                Section(header: Text("Summary")) {
                    NavigationLink(value: UUID()) {
                        Label("All Savings", systemImage: "dollarsign.circle.fill")
                    }
                }
                
                Section {
                    ForEach(viewModel.savingsJars) { jar in
                        NavigationLink(value: jar.id) {
                            HStack {
                                Image(systemName: jar.icon)
                                    .foregroundColor(viewModel.getColorFromString(jar.color))
                                Text(jar.name)
                                Spacer()
                                Text(viewModel.formatter.string(from: jar.currentAmount))
                                    .foregroundColor(.secondary)
                            }
                            .contextMenu {
                                Button {
                                    viewModel.showTransactionFor(jar: jar)
                                } label: {
                                    Label("Deposit / Withdraw", systemImage: "arrow.left.arrow.right.circle.fill")
                                }
                                
                                #if WIDGETS_ENABLED
                                Button {
                                    viewModel.selectJarForWidget(jar)
                                } label: {
                                    Label("Show in Widget", systemImage: "apps.iphone")
                                }
                                #endif
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteSavingsJar(at: indexSet)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
                
                ToolbarItemGroup(placement: .automatic) {
                    Menu {
                        Button(action: exportJarsAction) {
                            Label("Export Savings Jars", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: importJarsAction) {
                            Label("Import Savings Jars", systemImage: "square.and.arrow.down")
                        }
                        
                        Divider()
                        
                        #if WIDGETS_ENABLED
                        Button(action: {
                            showingWidgetConfig = true
                        }) {
                            Label("Configure Widget", systemImage: "apps.iphone")
                        }
                        #endif
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Divider()
                        
                        Button(action: showAboutView) {
                            Label("About", systemImage: "info.circle")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                    
                    Button(action: {
                        showingAddJar = true
                    }) {
                        Label("Add Jar", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("")
        } detail: {
            if let jarId = selectedJarId, jarId != UUID(), let jar = viewModel.savingsJars.first(where: { $0.id == jarId }) {
                SavingsJarDetailView(jar: jar, viewModel: viewModel)
            } else {
                // Overview screen
                SavingsOverviewView(savingsJars: viewModel.savingsJars, viewModel: viewModel)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .overlay {
            if showingAddJar {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingAddJar = false
                    }
                
                ZStack {
                    CustomAddJarView(viewModel: viewModel, isPresented: $showingAddJar)
                }
                .frame(width: 400, height: 550)
                .background(Color(.windowBackgroundColor))
                .cornerRadius(12)
                .shadow(radius: 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if showingSettings {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingSettings = false
                    }
                
                ZStack {
                    SettingsView(settingsManager: settingsManager, isPresented: $showingSettings)
                }
                .shadow(radius: 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            #if WIDGETS_ENABLED
            if showingWidgetConfig {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingWidgetConfig = false
                    }
                
                ZStack {
                    WidgetConfigView(viewModel: viewModel, isPresented: $showingWidgetConfig)
                }
                .shadow(radius: 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            #endif
        }
        .sheet(isPresented: $viewModel.showingTransactionPopup) {
            if let jar = viewModel.selectedJarForTransaction {
                TransactionSliderView(
                    jar: jar,
                    viewModel: viewModel,
                    isVisible: $viewModel.showingTransactionPopup
                )
                .frame(width: 380, height: 350)
                .padding([.horizontal, .top, .bottom], 10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingAddJar)
        .animation(.easeInOut(duration: 0.3), value: showingSettings)
        #if WIDGETS_ENABLED
        .animation(.easeInOut(duration: 0.3), value: showingWidgetConfig)
        #endif
        .environmentObject(settingsManager) // Make settings available throughout the app
        .onAppear {
            // Apply settings when app launches
            settingsManager.applyAppearanceSettings()
            
            // Configure view model with settings
            viewModel.configureWithSettings(settingsManager)
        }
    }
}
