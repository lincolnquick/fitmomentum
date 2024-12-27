//
//  WeightMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class WeightMeasurement: Measurement {
    
    required init(timestamp: Date, value: Double){
        super.init(timestamp: timestamp, value: value)
    }
    
    convenience init(timestamp: Date = Date(), weight: Double) {
        self.init(timestamp: timestamp, value: weight)
    }
    
    /// Weight in kg
    var weight: Double { return value }
    
    /// Validate that the weight is greater than 0
    override func validate() throws {
        guard value > 0 else {
            throw MeasurementError.invalidValue("Weight must be greater than zero.")
        }
    }
}
