//
//  GraphDisplay.swift
//  FitMomentum
//

import SwiftUI
import Charts
import Foundation

struct GraphDisplay: View {
    var selectedMetric: MetricType
    var selectedInterval: TimeIntervalType
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var scrollPosition: Date = Calendar.current.startOfDay(for: Date()) // Default to today
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
        .onChange(of: selectedInterval) { _, _ in loadChartData() }
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
        .chartXScale(domain: computeVisibleRange(for: selectedInterval, chartData: chartData) ?? defaultDateRange())
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $scrollPosition)
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
                AxisValueLabel(axisFormat.formatter.string(from: date))
            }
        }
    }
    
    @ViewBuilder
    private func renderAverageDisplay() -> some View {
        guard let visibleRange = computeVisibleRange(for: selectedInterval, chartData: chartData) else {
            return EmptyView()
        }
        
        let visibleData = chartData.filter { visibleRange.contains($0.startDate) }

        if visibleData.isEmpty {
            EmptyView()
        } else {
            let averageValue = visibleData.map(\.value).reduce(0, +) / Double(visibleData.count)
            let unitLabel = userViewModel.unitLabel(for: selectedMetric)

            VStack(alignment: .leading, spacing: 2) {
                Text("AVERAGE")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(averageValue, specifier: "%.1f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(unitLabel)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
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
            }
        }
    }
}
