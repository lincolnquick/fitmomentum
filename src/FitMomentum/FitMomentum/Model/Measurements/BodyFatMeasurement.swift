//
//  BodyFatMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class BodyFatMeasurement: Measurement {
    var bodyFatPercentage: Double // Stored as a fraction (e.g. 0.25 for 25%)
    
    init(bodyFatPercentage: Double, timestamp: Date = Date()) {
        self.bodyFatPercentage = bodyFatPercentage
        super.init(timestamp: timestamp)
    }
    
    /// Validate that the body fat percentage is between 0.0 and 1.0.
    override func validate() throws {
        guard bodyFatPercentage >= 0 && bodyFatPercentage <= 1.0 else {
            throw MeasurementError.invalidValue("Body fat percentage must be between 0.0 and 1.0.")
        }
    }
}
