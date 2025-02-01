//
//  MetricPicker.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//

import SwiftUI
import Charts
struct MetricPicker: View {
    @Binding var selectedMetric: MetricType

    var body: some View {
        HStack {
            Picker("Select Metric", selection: $selectedMetric) {
                ForEach(MetricType.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 200)
            .font(.headline)
        }
        .padding(.horizontal)
    }
}
