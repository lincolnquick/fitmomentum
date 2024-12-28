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
    /// If a measurement for the same day already exists, it will be replaced.
    /// - Parameter measurement: The measurement to add or update.
    func addOrUpdateMeasurement(_ measurement: T) throws {
        try measurement.validate()  // Validate before adding
        let normalizedDate = measurement.timestamp.onlyDate()
        measurements[normalizedDate] = measurement
    }
    
    /// Retrieve the measurement for a specific date.
    /// - Parameter date: The date for which to retrieve the measurement.
    /// - Returns: The measurement for the given date, if it exists.
    func getMeasurement(for date: Date) -> T? {
        let normalizedDate = date.onlyDate()
        return measurements[normalizedDate]
    }
    
    /// Delete the measurement for a specific date.
    /// - Parameter date: The date for which to delete the measurement.
    func deleteMeasurement(for date: Date) {
        let normalizedDate = date.onlyDate()
        measurements.removeValue(forKey: normalizedDate)
    }
    
    /// Get all measurements in chronological order.
    /// - Returns: A sorted array of all measurements.
    func getAllMeasurements() -> [T] {
        return measurements.values.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get the most recent measurement.
    /// - Returns: The most recent measurement, if available.
    func getMostRecentMeasurement() -> T? {
        return measurements.values.max(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get the earliest measurement
    /// - Returns: The first measurement, if available
    func getEarliestMeasurement() -> T? {
        return measurements.values.min(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Get measurements within a specified date range.
    /// - Parameters:
    ///   - startDate: The start date of the range (inclusive).
    ///   - endDate: The end date of the range (inclusive).
    /// - Returns: An array of measurements within the specified range.
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
}

/// Extension to normalize dates (strip time components).
extension Date {
    /// Normalize a date to include only the date components.
    func onlyDate() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
}

/// A protocol that defines the basic structure for a measurement.
protocol MeasurementProtocol {
    /// The date of the measurement.
    var timestamp: Date { get set }
    /// The generic value representing the measurement
    var value: Double { get set }
    
    /// Validates the measurement data.
    /// - Throws: An error if the measurement data is invalid.
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
