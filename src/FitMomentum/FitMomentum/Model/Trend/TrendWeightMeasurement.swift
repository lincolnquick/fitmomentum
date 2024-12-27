//
//  TrendWeightMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//
import Foundation
class TrendWeightMeasurement: WeightMeasurement, TrendMeasurementProtocol {
    var hasRecordedMeasurement: Bool
    var calculationMethod: String
    var calculatedAt: Date
    
    required init(timestamp: Date, value: Double) {
        self.hasRecordedMeasurement = false
        self.calculationMethod = ""
        self.calculatedAt = Date()
        super.init(timestamp: timestamp, value: value)
    }
    
    convenience init(
        hasRecordedMeasurement: Bool,
        calculationMethod: String,
        calculatedAt: Date = Date(),
        timestamp: Date,
        weight: Double
    ) {
        self.init(timestamp: timestamp, weight: weight)
        self.hasRecordedMeasurement = hasRecordedMeasurement
        self.calculationMethod = calculationMethod
        self.calculatedAt = calculatedAt
        
    }
    
    override func validate() throws {
        try super.validate()
        
        guard !calculationMethod.isEmpty else {
            throw MeasurementError.invalidValue("Calculation method cannot be empty.")
        }
    }
}
