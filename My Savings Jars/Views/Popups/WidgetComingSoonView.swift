//
//  WidgetComingSoonView.swift
//  Savings Jar
//
//  Created by Sean Sullivan on 3/18/25.
//

import SwiftUI
//import Savings_Jar

// A simple placeholder view to show when widget functionality
// is under development but not yet ready
struct WidgetComingSoonView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom title bar
            Color.blue
                .frame(height: 45)
                .overlay(
                    HStack {
                        Text("Widgets - Coming Soon")
                            .font(.fancyTitle)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                )
            
            VStack(spacing: 30) {
                // Icon
                Image(systemName: "apps.iphone")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                // Message
                VStack(spacing: 15) {
                    Text("Widget Support Coming Soon!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("We're working hard to bring widget support to Savings Jar. Soon you'll be able to track your savings progress directly from your home screen.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("Planned Features:")
                        .font(.headline)
                    
                    FeatureRow(icon: "square.grid.2x2", text: "Small, medium, and large widget sizes")
                    FeatureRow(icon: "hand.tap", text: "Choose which jar to feature")
                    FeatureRow(icon: "chart.pie", text: "See total progress across all jars")
                    FeatureRow(icon: "arrow.clockwise", text: "Live updates when you add or edit jars")
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // Close button
                Button("Close") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .frame(width: 480, height: 600)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
    }
}

// Row for each feature
struct FeatureRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// Preview
struct WidgetComingSoonView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetComingSoonView(isPresented: .constant(true))
    }
}
