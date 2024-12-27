//
//  BodyFatMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class BodyFatMeasurement: Measurement {
    
    required init(timestamp: Date, value: Double){
        super.init(timestamp: timestamp, value: value)
    }
    
    convenience init(timestamp: Date = Date(), bodyFatPercentage: Double) {
        self.init(timestamp: timestamp, value: bodyFatPercentage)
    }
    
    /// Body fat percentage as a decimal value (e.g. 0.25 for 25%)
    var bodyFatPercentage: Double { return value }
    
    /// Validate that the body fat percentage is between 0.0 and 1.0.
    override func validate() throws {
        guard value >= 0 && value <= 1.0 else {
            throw MeasurementError.invalidValue("Body fat percentage must be between 0.0 and 1.0.")
        }
    }
}
