//
//  IntervalTabs.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//


import SwiftUI
import Charts
struct IntervalTabs: View {
    @Binding var selectedInterval: TimeIntervalType

    var body: some View {
        HStack {
            ForEach(TimeIntervalType.allCases, id: \.self) { interval in
                Button(action: {
                    selectedInterval = interval
                }) {
                    Text(interval.rawValue)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selectedInterval == interval ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}
