//
//  DataTable.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//

import SwiftUI
import Charts

// MARK: - Data Table
struct DataTable: View {
    var selectedMetric: MetricType
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        List(userViewModel.getAllData(for: selectedMetric).sorted { $0.date > $1.date }) { data in
            HStack {
                Text(data.date.formatted(.dateTime.month().day().year()))
                Spacer()
                Text("\(userViewModel.formattedValue(data.value, for: selectedMetric)) \(userViewModel.unitLabel(for: selectedMetric))")
            }
        }
        .listStyle(PlainListStyle())
    }
}
