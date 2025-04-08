//
//  TotalSavingsHeaderView.swift
//  My Savings Jars
//
//  Created by Sean Sullivan on 4/8/25.
//

import SwiftUI

struct TotalSavingsHeaderView: View {
    let totalSaved: Double
    let totalTarget: Double
    let formatter: CurrencyFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Progress")
                        .font(.headline)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.2))
                                .frame(height: 20)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(min(1, totalSaved / totalTarget)), height: 20)
                        }
                    }
                    .frame(height: 20)

                    HStack {
                        Text("\(formatter.string(from: totalSaved)) of \(formatter.string(from: totalTarget))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(String(format: "%.1f%%", totalTarget > 0 ? (totalSaved / totalTarget * 100) : 0))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text(formatter.string(from: totalSaved))
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}
