//
//  ChartUtils.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/30/25.
//


import Foundation

/// Returns a formatter for day names (e.g., Mon, Tue)
func weekdayFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter
}

/// Returns a formatter for day numbers (e.g., 1, 7, 14, 21, 30)
func dayNumberFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}

/// Returns a formatter for abbreviated month names (e.g., Dec, Jan, Feb)
func shortMonthFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter
}

/// Returns a formatter for full years (e.g., 2024, 2025)
func yearFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
}

/// Computes the correct X-axis format based on the selected interval
func formatXAxis(interval: TimeIntervalType) -> AxisMarksFormat {
    switch interval {
    case .weekly:
        return AxisMarksFormat(unit: .day, formatter: weekdayFormatter(), stride: 1)
    case .monthly:
        return AxisMarksFormat(unit: .day, formatter: dayNumberFormatter(), stride: 7)
    case .threeMonths:
        return AxisMarksFormat(unit: .month, formatter: shortMonthFormatter(), stride: 1)
    case .yearly:
        return AxisMarksFormat(unit: .month, formatter: shortMonthFormatter(), stride: 1)
    case .allTime:
        return AxisMarksFormat(unit: .year, formatter: yearFormatter(), stride: 1)
    }
}

/// Computes the visible date range for a given interval
func computeVisibleRange(for interval: TimeIntervalType, chartData: [BinnedChartData]) -> ClosedRange<Date>? {
    guard let latestDate = chartData.max(by: { $0.date < $1.date })?.date else {
        return nil
    }

    let calendar = Calendar.current
    let startDate: Date?

    switch interval {
    case .weekly:
        startDate = calendar.date(byAdding: .day, value: -7, to: latestDate)
    case .monthly:
        startDate = calendar.date(byAdding: .month, value: -1, to: latestDate)
    case .threeMonths:
        startDate = calendar.date(byAdding: .month, value: -3, to: latestDate)
    case .yearly:
        startDate = calendar.date(byAdding: .year, value: -1, to: latestDate)
    case .allTime:
        return nil
    }

    guard let start = startDate else { return nil }
    return start...latestDate
}
