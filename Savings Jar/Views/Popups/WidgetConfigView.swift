//
//  WidgetConfigView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI
import WidgetKit

struct WidgetConfigView: View {
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom title bar
            Color.blue
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("Widget Configuration")
                            .font(.fancyTitle)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                )
            
            VStack(alignment: .leading, spacing: 20) {
                // Explanation text
                Text("Select which savings jar to feature in the widget. This will be shown in the small widget size and as the featured jar in the medium size.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                // Separator
                Divider()
                
                // Option for all jars
                Button(action: {
                    viewModel.clearWidgetJarSelection()
                }) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("All Savings")
                                .font(.headline)
                            
                            Text("Show total progress across all jars")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if viewModel.selectedWidgetJarId == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor).opacity(0.3))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                // List of jars
                Text("Select a Featured Jar")
                    .font(.headline)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.savingsJars) { jar in
                            Button(action: {
                                viewModel.selectJarForWidget(jar)
                            }) {
                                HStack {
                                    Image(systemName: jar.icon)
                                        .font(.title2)
                                        .foregroundColor(viewModel.getColorFromString(jar.color))
                                    
                                    VStack(alignment: .leading) {
                                        Text(jar.name)
                                            .font(.headline)
                                        
                                        Text("\(Int(jar.percentComplete * 100))% complete")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.isSelectedForWidget(jar) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.windowBackgroundColor).opacity(0.3))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Widget preview note
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Changes will appear in the widget after a few moments. You may need to add the Savings Jar widget to your home screen first.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Action buttons
                HStack {
                    Spacer()
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .frame(width: 480, height: 600)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }
}
