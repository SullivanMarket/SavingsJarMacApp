//
//  SidebarView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: SavingsViewModel
    var totalSaved: Double

    @Binding var selectedJarIndex: Int?
    @Binding var showingSettingsPopup: Bool
    @Binding var showingAddJarPopup: Bool
    @Binding var showingAboutPopup: Bool
    @Binding var showingExportPopup: Bool
    @Binding var showingImportPopup: Bool
    @Binding var showMenu: Bool
    @Binding var sidebarExpanded: Bool

    let formatter = CurrencyFormatter.shared

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color(red: 0.4, green: 0.4, blue: 0.8)
                    .frame(height: 60)
                    .ignoresSafeArea(edges: .top)
                Color.blue.opacity(0.1)
            }

            VStack(spacing: 0) {
                HStack {
                    Button(action: { showMenu.toggle() }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $showMenu, arrowEdge: .bottom) {
                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: { showingAddJarPopup = true; showMenu = false }) {
                                Label("Add New Jar", systemImage: "plus.circle")
                                    .frame(width: 200, alignment: .leading)
                            }
                            Button(action: { showingSettingsPopup = true; showMenu = false }) {
                                Label("Settings", systemImage: "gear")
                                    .frame(width: 200, alignment: .leading)
                            }
                            Button(action: { showingExportPopup = true; showMenu = false }) {
                                Label("Export Jars", systemImage: "square.and.arrow.up")
                                    .frame(width: 200, alignment: .leading)
                            }
                            Button(action: { showingImportPopup = true; showMenu = false }) {
                                Label("Import Jars", systemImage: "square.and.arrow.down")
                                    .frame(width: 200, alignment: .leading)
                            }
                            Button(action: { showingAboutPopup = true; showMenu = false }) {
                                Label("About", systemImage: "info.circle")
                                    .frame(width: 200, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(12)
                    }

                    Spacer()

                    Button(action: { withAnimation { sidebarExpanded.toggle() } }) {
                        Image(systemName: "sidebar.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(height: 60)
                .background(Color(red: 0.4, green: 0.4, blue: 0.8))

                Button(action: { selectedJarIndex = nil }) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("All Savings")
                            .font(.headline)
                        Spacer()
                        Text(formatter.string(from: totalSaved))
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(selectedJarIndex == nil ? Color.blue.opacity(0.2) : Color.clear)
                }
                .buttonStyle(PlainButtonStyle())

                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(Array(viewModel.savingsJars.enumerated()), id: \.element.id) { index, jar in
                            Button(action: { selectedJarIndex = index }) {
                                HStack {
                                    Image(systemName: jar.icon)
                                        .foregroundColor(getColor(jar.color))
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(jar.name).font(.headline)
                                        Text("\(formatter.string(from: jar.currentAmount)) / \(formatter.string(from: jar.targetAmount))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(String(format: "%.1f%%", jar.percentComplete * 100))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(selectedJarIndex == index ? Color.gray.opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 260)
        .background(Color(.windowBackgroundColor))
    }

    private func getColor(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        default: return .blue
        }
    }
}
