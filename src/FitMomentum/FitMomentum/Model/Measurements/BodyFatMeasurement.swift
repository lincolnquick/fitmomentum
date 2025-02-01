//
//  BodyFatMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class BodyFatMeasurement: Measurement {
    
    var selectedSecondaryProperty: KeyPath<BodyFatMeasurement, Double> = \BodyFatMeasurement.bodyFatPercentage
    
    required init(timestamp: Date, value: Double){
        super.init(timestamp: timestamp, value: value)
    }
    
    convenience init(timestamp: Date = Date(), bodyFatPercentage: Double) {
        self.init(timestamp: timestamp, value: bodyFatPercentage)
    }
    
    /// Body fat percentage as a decimal value (25.0 for 25%)
    var bodyFatPercentage: Double { return value }
    
    override var description: String {
        let formattedDate = timestamp.formatted(.dateTime.month(.abbreviated).day().year())
        return "[Body Fat Measurement] Fat%: \(value), Timestamp: \(formattedDate)"
    }
    
    override var secondaryValue: Double? {
        return self[keyPath: selectedSecondaryProperty]
    }
    
    /// Validate that the body fat percentage is between 0.0 and 100.0.
    override func validate() throws {
        guard value >= 0 && value <= 100.0 else {
            throw MeasurementError.invalidValue("Body fat percentage must be between 0 and 100.")
        }
    }
}
