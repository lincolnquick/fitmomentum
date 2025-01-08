//
//  TrendMeasurementCollection.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//

import Foundation

/// A collection to manage trend measurements of any type conforming to `TrendMeasurementProtocol`.
class TrendMeasurementCollection<T: MeasurementProtocol> {
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
    
    /// Calculate the moving average over a specified window size.
    func calculateMovingAverage(windowSize: Int, using property: (T) -> Double = { $0.value }) -> [Double] {
        let sortedMeasurements = getAllMeasurements()
        guard windowSize > 0 && sortedMeasurements.count >= windowSize else { return [] }
        return (0...(sortedMeasurements.count - windowSize)).map { index in
            let window = sortedMeasurements[index..<(index + windowSize)]
            return window.reduce(0.0) { $0 + property($1) } / Double(windowSize)
        }
    }
    
    /// Detect anomalies based on a percentage threshold.
    func detectAnomalies(thresholdPercentage: Double, using property: (T) -> Double = { $0.value }) -> [T] {
        let sortedMeasurements = getAllMeasurements()
        guard sortedMeasurements.count > 1 else { return [] }
        
        var anomalies: [T] = []
        for i in 1..<sortedMeasurements.count {
            let previous = property(sortedMeasurements[i - 1])
            let current = property(sortedMeasurements[i])
            let change = abs((current - previous) / previous) * 100
            if change >= thresholdPercentage {
                anomalies.append(sortedMeasurements[i])
            }
        }
        return anomalies
    }
    
    /// Forecast future trends using linear regression.
    func forecastLinearTrend(for days: Int, using property: (T) -> Double = { $0.value }) -> [Double] {
        let sortedMeasurements = getAllMeasurements()
        guard sortedMeasurements.count > 1 else { return [] }
        
        let values = sortedMeasurements.map(property)
        let timestamps = sortedMeasurements.map { $0.timestamp.timeIntervalSince1970 }
        
        let meanX = timestamps.reduce(0, +) / Double(timestamps.count)
        let meanY = values.reduce(0, +) / Double(values.count)
        
        let numerator = zip(timestamps, values).reduce(0.0) { $0 + ($1.0 - meanX) * ($1.1 - meanY) }
        let denominator = timestamps.reduce(0.0) { acc, timestamp in
            acc + pow(timestamp - meanX, 2)
        }
        
        guard denominator != 0 else { return [] }  // Avoid division by zero
        
        let slope = numerator / denominator
        let intercept = meanY - slope * meanX
        
        return (1...days).map { day in
            let futureTimestamp = timestamps.last! + Double(day * 86400)
            return slope * futureTimestamp + intercept
        }
    }
}
