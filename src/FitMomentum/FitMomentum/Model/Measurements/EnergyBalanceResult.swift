//
//  EnergyBalanceResult.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//
import Foundation
class EnergyBalanceResult: Measurement, TrendMeasurementProtocol {
    var hasRecordedMeasurement: Bool
    var calculationMethod: String
    var calculatedAt: Date
    
    var rmrKcal: Double // Resting Metabolic Rate (RMR) value in kcal
    var fmKg: Double // Fat Mass (FM) in kg
    var ffmKg: Double // Fat-Free Mass or Lean Mass (FFM) in kg
    
    required init(timestamp: Date = Date(), value: Double) {
        self.calculatedAt = Date()
        self.calculationMethod = "Forbes Model"
        self.hasRecordedMeasurement = false
        self.rmrKcal = 0.0
        self.fmKg = 0.0
        self.ffmKg = 0.0
        super.init(timestamp: timestamp, value: value)
        
    }
    convenience init(
        hasRecordedMeasurement: Bool = false,
        calculationMethod: String = "Forbes Model",
        calculatedAt: Date = Date(),
        timestamp: Date = Date(),
        teeKcal: Double,
        rmrKcal: Double,
        fmKg: Double,
        ffmKg: Double
    ) {
        self.init(timestamp: timestamp, value: teeKcal)
        self.hasRecordedMeasurement = hasRecordedMeasurement
        self.calculationMethod = calculationMethod
        self.calculatedAt = calculatedAt
        self.rmrKcal = rmrKcal
        self.fmKg = fmKg
        self.ffmKg = ffmKg
        
    }
    
    /// Primary value is Total Energy Expenditure or TEE in kcal/day
    var teeKcal: Double { return value }
    
    /// Validate that all kcal and kg values are non-negative.
    override func validate() throws {
        guard rmrKcal >= 0, teeKcal >= 0, fmKg >= 0, ffmKg >= 0 else {
            throw MeasurementError.invalidValue("Energy Balance values must be non-negative.")
        }
    }
}


