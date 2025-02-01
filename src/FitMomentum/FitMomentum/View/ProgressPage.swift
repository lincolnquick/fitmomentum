//
//  ProgressPage.swift
//

import SwiftUI
import Charts

struct ProgressPage: View {
    @EnvironmentObject var userViewModel: UserViewModel

    // MARK: - UI States
    @State private var selectedMetric: MetricType = .weight
    @State private var selectedInterval: TimeIntervalType = .weekly
    @State private var showDataPointPopup: Bool = false
    @State private var selectedDataPoint: (date: Date, value: Double)? = nil
    @State private var visibleDataRange: ClosedRange<Date>? // Controls scrolling/snapping
    @State private var rawSelectedDate: Date? = nil

    // MARK: - Computed Property for Chart Data
    private var chartData: [ChartData] {
        userViewModel.getAllData(for: selectedMetric)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 2) {
                // Metric Picker
                MetricPicker(selectedMetric: $selectedMetric)

                // Interval Selection Tabs
                IntervalTabs(selectedInterval: $selectedInterval)

                // Graph Display (Using Computed Property)
                GraphDisplay(selectedMetric: selectedMetric, selectedInterval: selectedInterval)
                    .environmentObject(userViewModel)

                // Data Table
                DataTable(selectedMetric: selectedMetric)
            }
            .navigationTitle("Progress")
            .onAppear {
                setInitialVisibleRange()
            }
            .onChange(of: selectedInterval) { _, _ in
                setInitialVisibleRange()
            }
            .onChange(of: selectedMetric) { _, _ in
                setInitialVisibleRange()
            }
        }
    }

    // MARK: - Helper Methods

    /// Calculates default range based on interval selection
    private func defaultRange() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()

        let start: Date
        let end: Date = now

        switch selectedInterval {
        case .weekly:
            start = calendar.date(byAdding: .day, value: -6, to: now)!
        case .monthly:
            start = calendar.date(byAdding: .day, value: -29, to: now)!
        case .threeMonths:
            start = calendar.date(byAdding: .day, value: -89, to: now)!
        case .yearly:
            start = calendar.date(byAdding: .year, value: -1, to: now)!
        case .allTime:
            start = chartData.first?.date ?? now.addingTimeInterval(-365 * 24 * 60 * 60) // Default: 1 year ago
        }

        return start...end
    }

    /// Sets initial visible range for the chart when switching intervals
    private func setInitialVisibleRange() {
        visibleDataRange = defaultRange()
    }

    /// Finds the closest data point when the user taps the graph.
    private func getClosestDataPoint(at location: CGPoint, in data: [ChartData]) -> ChartData? {
        return data.min(by: { abs($0.date.timeIntervalSince1970 - location.x) < abs($1.date.timeIntervalSince1970 - location.x) })
    }
}

