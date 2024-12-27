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
    
    init(
        weight: Double,
        timestamp: Date,
        hasRecordedMeasurement: Bool,
        calculationMethod: String,
        calculatedAt: Date = Date()
    ) {
        self.hasRecordedMeasurement = hasRecordedMeasurement
        self.calculationMethod = calculationMethod
        self.calculatedAt = calculatedAt
        super.init(weight: weight, timestamp: timestamp)
    }
    
    override func validate() throws {
        try super.validate()
        
        guard !calculationMethod.isEmpty else {
            throw MeasurementError.invalidValue("Calculation method cannot be empty.")
        }
    }
}
