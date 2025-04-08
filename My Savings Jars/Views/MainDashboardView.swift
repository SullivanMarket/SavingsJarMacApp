//  MainDashboardView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/29/25.

import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @ObservedObject var settingsManager: SettingsManager

    @State private var showingSettingsPopup = false
    @State private var showingAddJarPopup = false
    @State private var showingAboutPopup = false
    @State private var showingExportPopup = false
    @State private var showingImportPopup = false
    @State private var showingTransactionsPopup = false
    @State private var showingEditJarPopup = false
    @State private var sidebarExpanded = true
    @State private var selectedJarIndex: Int? = nil
    @State private var showMenu = false

    var body: some View {
        HStack(spacing: 0) {
            if sidebarExpanded {
                SidebarView(
                    viewModel: viewModel,
                    totalSaved: totalSaved,
                    selectedJarIndex: $selectedJarIndex,
                    showingSettingsPopup: $showingSettingsPopup,
                    showingAddJarPopup: $showingAddJarPopup,
                    showingAboutPopup: $showingAboutPopup,
                    showingExportPopup: $showingExportPopup,
                    showingImportPopup: $showingImportPopup,
                    showMenu: $showMenu,
                    sidebarExpanded: $sidebarExpanded
                )
            }

            MainContentView(
                viewModel: viewModel,
                selectedJarIndex: $selectedJarIndex,
                sidebarExpanded: $sidebarExpanded,
                showingEditJarPopup: $showingEditJarPopup,
                showingTransactionsPopup: $showingTransactionsPopup
            )
        }
        .sheet(isPresented: $showingSettingsPopup) {
            SettingsView(settingsManager: settingsManager, isPresented: $showingSettingsPopup)
                .frame(width: 480, height: 600)
        }
        .sheet(isPresented: $showingAddJarPopup) {
            CustomAddJarView(viewModel: viewModel, isPresented: $showingAddJarPopup)
                .frame(width: 400, height: 600)
        }
        .sheet(isPresented: $showingAboutPopup) {
            AboutPopupView(isPresented: $showingAboutPopup)
        }
        .sheet(isPresented: $showingExportPopup) {
            ExportJarsView(viewModel: viewModel, isPresented: $showingExportPopup)
        }
        .sheet(isPresented: $showingImportPopup) {
            ImportJarsView(viewModel: viewModel, isPresented: $showingImportPopup)
        }
        .sheet(isPresented: $showingTransactionsPopup) {
            if let selectedIndex = selectedJarIndex {
                TransactionsListView(viewModel: viewModel,
                                     jar: viewModel.savingsJars[selectedIndex],
                                     isPresented: $showingTransactionsPopup)
                    .frame(width: 500, height: 650)
            }
        }
        .sheet(isPresented: $showingEditJarPopup) {
            if let selectedJar = viewModel.selectedJarForEditing {
                EditJarView(viewModel: viewModel, jar: selectedJar, isPresented: $showingEditJarPopup)
                    .frame(width: 400, height: 600)
            }
        }
        .sheet(isPresented: $viewModel.showingTransactionPopup) {
            if let selectedJar = viewModel.selectedJarForTransaction {
                TransactionSliderView(viewModel: viewModel, jar: selectedJar, isPresented: $viewModel.showingTransactionPopup)
                    .frame(width: 400, height: 550)
            }
        }
    }

    private var totalSaved: Double {
        viewModel.savingsJars.reduce(0) { $0 + $1.currentAmount }
    }
}
