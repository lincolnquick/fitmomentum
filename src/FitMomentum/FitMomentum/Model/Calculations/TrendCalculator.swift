//
//  TrendCalculator.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//
import Foundation

/// A class to calculate a TrendMeasurementCollection from a MeasurementCollection.
class TrendCalculator {
    
    /// Calculate trend measurements using a moving average. Fills in gaps in measured data.
    /// - Parameters:
    ///   - measurements: The input collection of measurements.
    ///   - windowSize: The number of days in the moving average window.
    /// - Returns: A `TrendMeasurementCollection` containing smoothed measurements.
    func calculateTrend<T: TrendWeightMeasurement>(for measurements: MeasurementCollection<T>, windowSize: Int) -> TrendMeasurementCollection<T> {
        let allMeasurements = measurements.getAllMeasurements()
        guard !allMeasurements.isEmpty else {
            return TrendMeasurementCollection<T>() // Empty collection
        }

        // Generate daily range
        let startDate = allMeasurements.first!.timestamp.onlyDate()
        let endDate = allMeasurements.last!.timestamp.onlyDate()
        var trendMeasurements = TrendMeasurementCollection<T>()

        // Iterate over the date range
        for date in stride(from: startDate, through: endDate, by: 1) {
            // Calculate moving average for the date
            let windowMeasurements = allMeasurements.filter {
                let dayDifference = Calendar.current.dateComponents([.day], from: $0.timestamp.onlyDate(), to: date).day!
                return abs(dayDifference) < windowSize
            }
            let averageValue = windowMeasurements.map { $0.value }.reduce(0, +) / Double(windowMeasurements.count)

            // Create a new trend measurement
            let hasRecordedMeasurement = allMeasurements.contains { $0.timestamp.onlyDate() == date }
            let calculationMethod = "\(windowSize)-day moving average"
            let calculatedAt = Date()

            if let referenceMeasurement = allMeasurements.first {
                let trendMeasurement = T(
                    timestamp: date,
                    value: averageValue
                )
                trendMeasurement.hasRecordedMeasurement = hasRecordedMeasurement
                trendMeasurement.calculationMethod = calculationMethod
                trendMeasurement.calculatedAt = calculatedAt
                do {
                    try trendMeasurements.addOrUpdateMeasurement(trendMeasurement)
                } catch {
                    print (error.localizedDescription)
                }
                
            }
        }

        return trendMeasurements
    }
}

