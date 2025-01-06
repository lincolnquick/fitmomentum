//
//  TrendMeasurementCollection.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//
import Foundation

/// A collection to manage trend measurements of any type conforming to `TrendMeasurementProtocol`.
class TrendMeasurementCollection<T: MeasurementProtocol> {
    private var measurements: [T] = []

    // Add a measurement to the collection
    func addMeasurement(_ measurement: T) {
        measurements.append(measurement)
        measurements.sort(by: { $0.timestamp < $1.timestamp })
    }

    // Calculate moving average
    func calculateMovingAverage(windowSize: Int) -> [Double] {
        guard windowSize > 0 && measurements.count >= windowSize else { return [] }
        return (0...(measurements.count - windowSize)).map { index in
            let window = measurements[index..<(index + windowSize)]
            return window.reduce(0.0, { $0 + $1.value }) / Double(windowSize)
        }
    }

    // Detect anomalies
    func detectAnomalies(thresholdPercentage: Double) -> [T] {
        guard measurements.count > 1 else { return [] }
        var anomalies: [T] = []
        for i in 1..<measurements.count {
            let previous = measurements[i - 1]
            let current = measurements[i]
            let change = abs((current.value - previous.value) / previous.value) * 100
            if change >= thresholdPercentage {
                anomalies.append(current)
            }
        }
        return anomalies
    }

    // Forecast future trends
    func forecastLinearTrend(for days: Int) -> [Double] {
        guard measurements.count > 1 else { return [] }
        let values = measurements.map { $0.value }
        let timestamps = measurements.map { $0.timestamp.timeIntervalSince1970 }
        let meanX = timestamps.reduce(0, +) / Double(timestamps.count)
        let meanY = values.reduce(0, +) / Double(values.count)
        let numerator = zip(timestamps, values).reduce(0.0) { $0 + ($1.0 - meanX) * ($1.1 - meanY) }
        let denominator = timestamps.reduce(0.0) { acc, timestamp in
            acc + pow(timestamp - meanX, 2)
        }
        let slope = numerator / denominator
        let intercept = meanY - slope * meanX

        return (1...days).map { day in
            let futureTimestamp = timestamps.last! + Double(day * 86400)
            return slope * futureTimestamp + intercept
        }
    }
}
