//
//  ChartDataModels.swift
//  FitMomentum
//

import Foundation

/// Represents a binned data point with additional metadata for time intervals
struct BinnedChartData: Identifiable {
    let id = UUID()
    let date: Date // Binned date (e.g., start of a week, month, etc.)
    let startDate: Date // First actual data point in the bin
    let endDate: Date // Last actual data point in the bin
    let value: Double
    let secondaryValue: Double?
}

/// Defines the axis formatting for different time intervals
struct AxisMarksFormat {
    var unit: Calendar.Component
    var formatter: DateFormatter
    var stride: Int
}
