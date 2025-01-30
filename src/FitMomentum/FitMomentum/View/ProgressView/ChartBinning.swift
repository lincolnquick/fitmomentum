//
//  ChartBinning.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/30/25.
//


import Foundation

/// Bins raw chart data based on the selected interval
func binData(_ data: [ChartData], by interval: TimeIntervalType) -> [BinnedChartData] {
    guard !data.isEmpty else { return [] }

    let calendar = Calendar.current
    let firstWeekday = calendar.firstWeekday // Get system’s preferred first day of the week
    var groupedData: [Date: [ChartData]] = [:]

    // Group data by bin date
    for point in data {
        let binDate = getBinDate(for: point.date, using: calendar, interval: interval, firstWeekday: firstWeekday)
        groupedData[binDate, default: []].append(point)
    }

    // Process each bin to calculate startDate, endDate, and averages
    let processedData = groupedData.map { (binnedDate, values) in
        let startDate = values.first?.date ?? binnedDate // Ensure actual first data point
        let endDate = values.last?.date ?? binnedDate // Ensure actual last data point

        let avgValue = values.map(\.value).reduce(0, +) / Double(values.count)
        let avgSecondary = values.compactMap(\.secondaryValue).reduce(0, +) / max(1, Double(values.compactMap(\.secondaryValue).count))

        return BinnedChartData(
            date: binnedDate,
            startDate: startDate,
            endDate: endDate,
            value: avgValue,
            secondaryValue: avgSecondary
        )
    }
    .sorted { $0.date < $1.date }

    return processedData
}

/// Determines the binning date based on the interval
func getBinDate(for date: Date, using calendar: Calendar, interval: TimeIntervalType, firstWeekday: Int) -> Date {
    switch interval {
    case .weekly, .monthly:
        // Daily binning
        return calendar.startOfDay(for: date)

    case .threeMonths:
        // Weekly binning using the system's preferred first weekday
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = firstWeekday
        return calendar.date(from: components) ?? date

    case .yearly, .allTime:
        // Monthly binning
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}
