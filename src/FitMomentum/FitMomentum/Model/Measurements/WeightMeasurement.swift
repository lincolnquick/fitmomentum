//
//  WeightMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class WeightMeasurement: Measurement {
    var weight: Double // in kg
    
    init(weight: Double, timestamp: Date = Date()) {
        self.weight = weight
        super.init(timestamp: timestamp)
    }
    
    /// Validate that the weight is greater than 0
    override func validate() throws {
        guard weight > 0 else {
            throw MeasurementError.invalidValue("Weight must be greater than zero.")
        }
    }
}
