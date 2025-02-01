//
//  GraphDisplay.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//

import SwiftUI
import Charts

struct GraphDisplay: View {
    var selectedMetric: MetricType
    var selectedInterval: TimeIntervalType
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var scrollPosition: Date = Calendar.current.startOfDay(for: Date()) // Assuming weekly view is the default
    @State private var xScale: ClosedRange<Date>?
    @State private var chartData: [BinnedChartData] = []
    
    

    var body: some View {
        VStack {
            renderAverageDisplay()
            if chartData.isEmpty {
                renderNoDataView()
            } else {
                renderChart()
            }
        }
        .onAppear { loadChartData() }
        .onAppear {
            if let latestDate = chartData.max(by: { $0.date < $1.date })?.date {
                scrollPosition = calculateStartOfInterval(for: selectedInterval, referenceDate: latestDate)
            }
        }
        .onChange(of: selectedInterval) { _,_ in loadChartData() }
    }
    
    // MARK: - Chart Rendering
    
    @ViewBuilder
    private func renderNoDataView() -> some View {
        Text("No data available for \(selectedMetric.rawValue).")
            .foregroundColor(.gray)
            .padding()
    }

    @ViewBuilder
    private func renderChart() -> some View {
        Chart {
            renderChartLines()
        }
        .chartXAxis { renderXAxis() }
        .chartXScale(domain: computeInitialXDomain(for: selectedInterval))
        .chartXVisibleDomain(length: computeVisibleDomain(for: selectedInterval))
        .chartYScale(domain: computeVisibleYRange())
        .frame(maxWidth: .infinity)
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $scrollPosition)
        .onChange(of: scrollPosition) {
            print("Scroll Position: \($scrollPosition)")
        }
    }

    @ChartContentBuilder
    private func renderChartLines() -> some ChartContent {
        ForEach(chartData) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Value", dataPoint.value)
            )
            .foregroundStyle(Color.blue)
            .symbol(.circle)
        }
    }
    

    @AxisContentBuilder
    private func renderXAxis() -> some AxisContent {
        let axisFormat = formatXAxis(interval: selectedInterval)
        AxisMarks(position: .bottom, values: .stride(by: axisFormat.unit, count: axisFormat.stride)) { value in
            AxisGridLine()
            AxisTick()
            if let date = value.as(Date.self) {
                if selectedInterval == .allTime {
                    AxisValueLabel(yearFormatter().string(from: date))
                } else {
                    AxisValueLabel(axisFormat.formatter.string(from: date))
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderAverageDisplay() -> some View {
        let visibleXDomain = calculateVisibleXDomain(for: selectedInterval, scrollPosition: scrollPosition)
        
        let visibleData = chartData.filter { visibleXDomain.contains($0.startDate) }

        if visibleData.isEmpty {
            EmptyView() // Ensure a valid return type
        } else {
            let averageValue = visibleData.map(\.value).reduce(0, +) / Double(visibleData.count)
            let dateRange = formatAverageDateRange(for: visibleData)
            let unitLabel = userViewModel.unitLabel(for: selectedMetric) // Fetch unit dynamically

            VStack(alignment: .leading, spacing: 2) {
                Text("AVERAGE") // Small, all caps label
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(averageValue, specifier: "%.1f")") // Prominent value
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(unitLabel) // Correct unit for metric
                        .font(.title3)
                        .foregroundColor(.gray)
                }.frame(maxWidth: .infinity, alignment: .leading)

                Text(dateRange) //  Formatted date range below the value
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(5)
            
        }
    }
    
    // MARK: - Data Loading

    private func loadChartData() {
        Task {
            let rawData = userViewModel.getAllData(for: selectedMetric)

            let binnedData = binData(rawData, by: selectedInterval)

            await MainActor.run {
                chartData = binnedData
                if let latestDate = binnedData.max(by: {$0.date < $1.date})?.date {
                    scrollPosition = latestDate
                }
            }
        }
    }

    private func binData(_ data: [ChartData], by interval: TimeIntervalType) -> [BinnedChartData] {
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

    private func getBinDate(for date: Date, using calendar: Calendar, interval: TimeIntervalType, firstWeekday: Int) -> Date {
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

    // MARK: - Axis Configuration

    private func formatXAxis(interval: TimeIntervalType) -> AxisMarksFormat {
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
    
    private func calculateActiveRange(for interval: TimeIntervalType, visibleRange: ClosedRange<Date>) -> ClosedRange<Date> {
        let calendar = Calendar.current

        let startDate = visibleRange.lowerBound
        var endDate = visibleRange.upperBound

        switch interval {
        case .weekly:
            // Limit activeRange to exactly 7 days
            endDate = calendar.date(byAdding: .day, value: 6, to: startDate) ?? endDate

        case .monthly:
            let startMonth = calendar.component(.month, from: startDate)
            let endMonth = calendar.component(.month, from: endDate)

            // Limit activeRange to the actual number of days in the month
            if startMonth != endMonth {
                let monthDays = calendar.range(of: .day, in: .month, for: startDate)?.count ?? 30
                endDate = calendar.date(byAdding: .day, value: monthDays - 1, to: startDate) ?? endDate
            }

        case .threeMonths:
            //  Limit activeRange to exactly 3 months
            endDate = calendar.date(byAdding: .month, value: 3, to: startDate) ?? endDate
            endDate = calendar.date(byAdding: .day, value: -1, to: endDate) ?? endDate

        case .yearly:
            //  Limit activeRange to exactly 12 months
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? endDate
            endDate = calendar.date(byAdding: .day, value: -1, to: endDate) ?? endDate

        case .allTime:
            //  No restriction needed, covers entire dataset
            break
        }

        return startDate...endDate
    }
    
    private func computeVisibleDomain(for interval: TimeIntervalType) -> TimeInterval {
        guard let earliestDate = chartData.min(by: { $0.date < $1.date })?.date,
              let latestDate = chartData.max(by: { $0.date < $1.date })?.date else {
            return 3600 * 24 * 365 * 8 // Fallback: 8 years
        }

        let range = latestDate.timeIntervalSince(earliestDate)
        let visibleDomain: TimeInterval

        switch interval {
        case .weekly:
            visibleDomain = min(range, 3600 * 24 * 7) // Show last 7 days
        case .monthly:
            visibleDomain = min(range, 3600 * 24 * 30) // Show last 1 month
        case .threeMonths:
            visibleDomain = min(range, 3600 * 24 * 90) // Show last 3 months
        case .yearly:
            visibleDomain = min(range, 3600 * 24 * 365) // Show last 1 year
        case .allTime:
            visibleDomain = range // Show entire dataset
        }
        
        print("[GraphDisplay.computeVisibleDomain] visibleDomain: \(visibleDomain)")
        return visibleDomain
    }
    
    private func calculateStartOfInterval(for interval: TimeIntervalType, referenceDate: Date) -> Date {
        let calendar = Calendar.current

        switch interval {
        case .weekly:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate)) ?? referenceDate

        case .monthly:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) ?? referenceDate

        case .threeMonths:
            let adjustedDate = calendar.date(byAdding: .month, value: -2, to: referenceDate) ?? referenceDate
            return calendar.date(from: calendar.dateComponents([.year, .month], from: adjustedDate)) ?? adjustedDate

        case .yearly:
            return calendar.date(from: calendar.dateComponents([.year], from: referenceDate)) ?? referenceDate

        case .allTime:
            return chartData.first?.date ?? referenceDate
        }
    }
    
    private func calculateVisibleXDomain(for interval: TimeIntervalType, scrollPosition: Date) -> ClosedRange<Date> {
        let calendar = Calendar.current

        // Ensure scrollPosition aligns with a valid date in chartData
        let adjustedScrollPosition = chartData
            .map(\.date)
            .min(by: { abs($0.timeIntervalSince(scrollPosition)) < abs($1.timeIntervalSince(scrollPosition)) }) ?? scrollPosition

        let firstDataPoint = chartData.first?.date ?? adjustedScrollPosition
        let lastDataPoint = chartData.last?.date ?? adjustedScrollPosition

        var startDate = adjustedScrollPosition
        var endDate: Date

        switch interval {
        case .weekly:
            endDate = calendar.date(byAdding: .day, value: 6, to: startDate)! // Show exactly 7 days

        case .monthly:
            let monthRange = calendar.range(of: .day, in: .month, for: startDate) ?? 30..<31
            let daysInMonth = monthRange.upperBound - monthRange.lowerBound
            endDate = calendar.date(byAdding: .day, value: daysInMonth - 1, to: startDate)! // Show full month

        case .threeMonths:
            endDate = calendar.date(byAdding: .month, value: 3, to: startDate)!
            endDate = calendar.date(byAdding: .day, value: -1, to: endDate)! // Show exactly 3 months

        case .yearly:
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
            endDate = calendar.date(byAdding: .day, value: -1, to: endDate)! // Show exactly 1 year

        case .allTime:
            startDate = firstDataPoint
            endDate = lastDataPoint
        }

        // Ensure domain stays within available dataset bounds
        startDate = max(startDate, firstDataPoint)
        endDate = min(endDate, lastDataPoint)

        print("[GraphDisplay.calculateVisibleXDomain] Interval: \(interval), Start: \(startDate), End: \(endDate)")

        return startDate...endDate
    }
    
    private func computeScrollableRange(for interval: TimeIntervalType, withBuffer: Bool = false) -> ClosedRange<Date>? {
        guard let latestDate = chartData.max(by: { $0.date < $1.date })?.date else { return nil }

        let calendar = Calendar.current
        let startDate: Date? = {
            switch interval {
            case .weekly:
                return calendar.date(byAdding: .day, value: -30, to: latestDate) //  Ensure enough past data
            case .monthly:
                return calendar.date(byAdding: .month, value: -6, to: latestDate) //  Ensure at least 6 months visible
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: latestDate) //  Show at least 3 months
            case .yearly:
                return calendar.date(byAdding: .year, value: -5, to: latestDate) // Show 5 years of history
            case .allTime:
                return chartData.min(by: { $0.date < $1.date })?.date //  Show entire dataset
            }
        }()

        guard let start = startDate else { return nil }

        // Add buffer to the end date
        let buffer: TimeInterval = {
            switch interval {
            case .weekly: return 3600 * 24 //  Add 1 extra day
            case .monthly: return 3600 * 24 * 3 // Add 3 extra days
            case .threeMonths: return 3600 * 24 * 7 //  Add 1 extra week
            case .yearly: return 3600 * 24 * 15 //  Add 15 extra days
            case .allTime: return 3600 * 24 * 30 //  Add 1 extra month
            }
        }()

        let adjustedEnd = latestDate.addingTimeInterval(buffer)

        return start...adjustedEnd
    }
    
    private func computeInitialXDomain(for interval: TimeIntervalType) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let latestDate = chartData.max(by: { $0.date < $1.date })?.date ?? Date()
        let startDate: Date

        switch interval {
        case .weekly:
            startDate = calendar.date(byAdding: .day, value: -6, to: latestDate)! // Show 7 days
        case .monthly:
            startDate = calendar.date(byAdding: .month, value: -1, to: latestDate)! // Show 1 month
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: latestDate)! // Show 3 months
        case .yearly:
            startDate = calendar.date(byAdding: .year, value: -1, to: latestDate)! // Show 1 year
        case .allTime:
            startDate = chartData.first?.date ?? latestDate // Show entire dataset
        }

        return startDate...latestDate
    }
    
    private func computeVisibleRange(for interval: TimeIntervalType) -> ClosedRange<Date>? {
        guard let latestDate = chartData.max(by: { $0.date < $1.date })?.date else {
            return nil
        }

        let calendar = Calendar.current
        let startDate: Date? = {
            switch interval {
            case .weekly:
                return calendar.date(byAdding: .day, value: -7, to: latestDate)
            case .monthly:
                return calendar.date(byAdding: .day, value: -30, to: latestDate)
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: latestDate)
            case .yearly:
                return calendar.date(byAdding: .year, value: -1, to: latestDate)
            case .allTime:
                return nil
            }
        }()

        guard let start = startDate else { return nil }
        return start...latestDate
    }
    
    private func computeVisibleYRange() -> ClosedRange<Double> {
        guard let visibleRange = computeScrollableRange(for: selectedInterval),
              let minValue = chartData.filter({ visibleRange.contains($0.startDate) || visibleRange.contains($0.endDate)}).min(by: { $0.value < $1.value })?.value,
              let maxValue = chartData.filter({ visibleRange.contains($0.startDate) || visibleRange.contains($0.endDate)}).max(by: { $0.value < $1.value })?.value else {
            return 0...300 // Default if no data is available
        }

        // Add a small buffer to prevent values from touching edges
        let rangePadding = (maxValue - minValue) * 0.1
        let adjustedMin = max(0, minValue - rangePadding) // Ensure no negative values
        let adjustedMax = maxValue + rangePadding


        return adjustedMin...adjustedMax
    }
    
    private func defaultDateRange() -> ClosedRange<Date> {
        let start = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        return start...Date()
    }

    // MARK: - Date Formatters

    private func weekdayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }

    private func dayNumberFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    private func shortMonthFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }

    private func yearFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    private func formatAverageDateRange(for data: [BinnedChartData]) -> String {
        guard let firstDate = data.first?.date, let lastDate = data.last?.date else { return "" }
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        switch selectedInterval {
        case .weekly:
            dateFormatter.dateFormat = "MMM d, yyyy" // Example: Jan 2, 2024
            return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"

        case .monthly:
            if calendar.isDate(firstDate, equalTo: lastDate, toGranularity: .month) {
                dateFormatter.dateFormat = "MMM yyyy" // Example: Jan 2024
                return dateFormatter.string(from: firstDate)
            } else {
                dateFormatter.dateFormat = "MMM d, yyyy"
                return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"
            }

        case .threeMonths:
            dateFormatter.dateFormat = "MMM d, yyyy"
            return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"

        case .yearly:
            if calendar.isDate(firstDate, equalTo: lastDate, toGranularity: .year) {
                dateFormatter.dateFormat = "yyyy" // Example: 2024
                return dateFormatter.string(from: firstDate)
            } else {
                dateFormatter.dateFormat = "MMM d, yyyy"
                return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"
            }

        case .allTime:
            dateFormatter.dateFormat = "MMM d, yyyy"
            return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"
        }
    }
}

// MARK: - AxisMarksFormat Struct
private struct AxisMarksFormat {
    var unit: Calendar.Component
    var formatter: DateFormatter
    var stride: Int
}

struct BinnedChartData: Identifiable {
    let id = UUID()
    let date: Date // Binned Date
    let startDate: Date
    let endDate: Date
    let value: Double
    let secondaryValue: Double?
}

