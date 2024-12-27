//
//  TrendBodyFatMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//
import Foundation
class TrendBodyFatMeasurement : BodyFatMeasurement, TrendMeasurementProtocol {
    var hasRecordedMeasurement: Bool
    var calculationMethod: String
    var calculatedAt: Date
    
    init(
        hasRecordedMeasurement: Bool,
        calculationMethod: String,
        calculatedAt: Date = Date(),
        bodyFatPercentage: Double,
        timestamp: Date
    ) {
        self.hasRecordedMeasurement = hasRecordedMeasurement
        self.calculationMethod = calculationMethod
        self.calculatedAt = calculatedAt
        super.init(bodyFatPercentage: bodyFatPercentage, timestamp: timestamp)
    }
    
    override func validate() throws {
        try super.validate()
        
        guard !calculationMethod.isEmpty else {
            throw MeasurementError.invalidValue("Calculation method cannot be empty.")
        }
    }
    
    
    
}
