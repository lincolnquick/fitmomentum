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
    var teeKcal: Double // Total Energy Expenditure (TEE) value in kcal
    var fmKg: Double // Fat Mass (FM) in kg
    var ffmKg: Double // Fat-Free Mass or Lean Mass (FFM) in kg
    
    init(
        hasRecordedMeasurement: Bool = false,
        calculationMethod: String = "Forbes Model",
        calculatedAt: Date = Date(),
        rmrKcal: Double,
        teeKcal: Double,
        fmKg: Double,
        ffmKg: Double,
        timestamp: Date = Date()
    ) {
            self.hasRecordedMeasurement = hasRecordedMeasurement
            self.calculationMethod = calculationMethod
            self.calculatedAt = calculatedAt
            self.rmrKcal = rmrKcal
            self.teeKcal = teeKcal
            self.fmKg = fmKg
            self.ffmKg = ffmKg
            super.init(timestamp: timestamp)
    }
    
    /// Validate that all kcal and kg values are non-negative.
    override func validate() throws {
        guard rmrKcal >= 0, teeKcal >= 0, fmKg >= 0, ffmKg >= 0 else {
            throw MeasurementError.invalidValue("Energy Balance values must be non-negative.")
        }
    }
}


