//
//  Measurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class Measurement : MeasurementProtocol {
    var timestamp: Date
    var value: Double // generic value for the measurement
    
    required init(timestamp: Date = Date(), value: Double) {
        self.timestamp = timestamp
        self.value = value
    }
    var description: String {
        let formattedDate = timestamp.formatted(.dateTime.month(.abbreviated).day().year())
        return "Measurement: \(type(of: self)), Value: \(value), Timestamp: \(formattedDate)"
    }
    
    func validate() throws {
        guard value >= 0 else {
            throw MeasurementError.invalidValue("Value must be non-negative.")
        }
    }
}
