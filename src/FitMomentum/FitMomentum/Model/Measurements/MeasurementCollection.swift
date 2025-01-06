//
//  MeasurementCollection.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//

import Foundation

/// Generic collection to manage measurements of any type conforming to `MeasurementProtocol`.
class MeasurementCollection<T: MeasurementProtocol> {
    private var measurements: [Date: T] = [:]  // Dictionary keyed by normalized date
    
    /// Add or update a measurement for the given day.
    func addOrUpdateMeasurement(_ measurement: T) throws {
        try measurement.validate()
        let normalizedDate = measurement.timestamp.onlyDate()
        measurements[normalizedDate] = measurement
    }
    
    /// Retrieve the measurement for a specific date.
    func getMeasurement(for date: Date) -> T? {
        let normalizedDate = date.onlyDate()
        return measurements[normalizedDate]
    }
    
    /// Delete the measurement for a specific date.
    func deleteMeasurement(for date: Date) {
        let normalizedDate = date.onlyDate()
        measurements.removeValue(forKey: normalizedDate)
    }
    
    /// Get all measurements in chronological order.
    func getAllMeasurements() -> [T] {
        return measurements.values.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get the most recent measurement.
    func getMostRecentMeasurement() -> T? {
        return measurements.values.max(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get the earliest measurement.
    func getEarliestMeasurement() -> T? {
        return measurements.values.min(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get measurements within a specified date range.
    func getMeasurements(from startDate: Date, to endDate: Date) -> [T] {
        let normalizedStart = startDate.onlyDate()
        let normalizedEnd = endDate.onlyDate()
        return measurements.filter { $0.key >= normalizedStart && $0.key <= normalizedEnd }
            .map { $0.value }
            .sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get the count of measurements in the collection.
    var count: Int {
        return measurements.count
    }
    
    /// Check if the collection is empty.
    var isEmpty: Bool {
        return measurements.isEmpty
    }
    
    /// Calculate the average (mean) value for a date range.
    func calculateAverage(from startDate: Date, to endDate: Date, using property: (T) -> Double = { $0.value }) -> Double? {
        let rangeMeasurements = getMeasurements(from: startDate, to: endDate)
        guard !rangeMeasurements.isEmpty else { return nil }
        let total = rangeMeasurements.reduce(0) { $0 + property($1) }
        return total / Double(rangeMeasurements.count)
    }
    
    /// Calculate the median value for a date range.
    func calculateMedian(from startDate: Date, to endDate: Date, using property: (T) -> Double = { $0.value }) -> Double? {
        let rangeMeasurements = getMeasurements(from: startDate, to: endDate)
        guard !rangeMeasurements.isEmpty else { return nil }
        let sortedValues = rangeMeasurements.map(property).sorted()
        let count = sortedValues.count
        if count % 2 == 0 {
            return (sortedValues[count / 2 - 1] + sortedValues[count / 2]) / 2
        } else {
            return sortedValues[count / 2]
        }
    }
    
    /// Calculate the minimum value for a date range.
    func calculateMin(from startDate: Date, to endDate: Date, using property: (T) -> Double = { $0.value }) -> Double? {
        let rangeMeasurements = getMeasurements(from: startDate, to: endDate)
        return rangeMeasurements.map(property).min()
    }
    
    /// Calculate the maximum value for a date range.
    func calculateMax(from startDate: Date, to endDate: Date, using property: (T) -> Double = { $0.value }) -> Double? {
        let rangeMeasurements = getMeasurements(from: startDate, to: endDate)
        return rangeMeasurements.map(property).max()
    }
}

/// Extension to normalize dates (strip time components).
extension Date {
    func onlyDate() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
}

/// A protocol that defines the basic structure for a measurement.
protocol MeasurementProtocol {
    var timestamp: Date { get set }
    var value: Double { get set }
    func validate() throws
}

/// Example error for validation.
enum MeasurementError: Error, CustomStringConvertible {
    case invalidValue(String)
    var description: String {
        switch self {
        case .invalidValue(let message):
            return message
        }
    }
}
