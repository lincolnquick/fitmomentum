//
//  TrendMeasurementCollection.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//
import Foundation

/// A collection to manage trend measurements of any type conforming to `TrendMeasurementProtocol`.
class TrendMeasurementCollection<T: Measurement & TrendMeasurementProtocol>: MeasurementCollection<T> {
    /// Adds or updates a trend measurement in the collection.
    /// Ensures the measurement conforms to the `TrendMeasurementProtocol` requirements.
    /// - Parameter measurement: The trend measurement to add or update.
    override func addOrUpdateMeasurement(_ measurement: T) throws {
        // Validate trend-specific properties
        try measurement.validate()
        guard !measurement.calculationMethod.isEmpty else {
            throw MeasurementError.invalidValue("Calculation method cannot be empty.")
        }
        
        // Call the superclass method to add or update the measurement
        try super.addOrUpdateMeasurement(measurement)
    }

    /// Filters and retrieves trend measurements based on their calculation method.
    /// - Parameter method: The calculation method to filter by.
    /// - Returns: An array of trend measurements that use the specified method.
    func getMeasurements(byCalculationMethod method: String) -> [T] {
        return getAllMeasurements().filter { $0.calculationMethod == method }
    }

    /// Retrieves the most recently calculated trend measurement.
    /// - Returns: The most recent trend measurement, if available.
    func getMostRecentlyCalculated() -> T? {
        return getAllMeasurements().max(by: { $0.calculatedAt < $1.calculatedAt })
    }

    /// Retrieves trend measurements that have recorded measurements.
    /// - Returns: An array of trend measurements with recorded measurements.
    func getHasRecordedMeasurements() -> [T] {
        return getAllMeasurements().filter { $0.hasRecordedMeasurement }
    }

    /// Retrieves trend measurements that do not have recorded measurements.
    /// - Returns: An array of trend measurements without recorded measurements.
    func getHasUnrecordedMeasurements() -> [T] {
        return getAllMeasurements().filter { !$0.hasRecordedMeasurement }
    }

    /// Retrieves trend measurements calculated on a specific date.
    /// - Parameter date: The date to filter by.
    /// - Returns: An array of trend measurements calculated on the specified date.
    func getMeasurements(calculatedOn date: Date) -> [T] {
        let normalizedDate = date.onlyDate()
        return getAllMeasurements().filter { $0.calculatedAt.onlyDate() == normalizedDate }
    }
}



