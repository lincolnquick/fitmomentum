//
//  EnergyBalanceResult.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//
import Foundation
class EnergyBalanceResult: Measurement {
    var rmrKcal: Double // Resting Metabolic Rate (RMR) value in kcal
    var teeKcal: Double // Total Energy Expenditure (TEE) value in kcal
    var fmKg: Double // Fat Mass (FM) in kg
    var ffmKg: Double // Fat-Free Mass or Lean Mass (FFM) in kg
    
    init(rmrKcal: Double, teeKcal: Double, fmKg: Double, ffmKg: Double, timestamp: Date = Date()) {
        self.rmrKcal = rmrKcal
        self.teeKcal = teeKcal
        self.fmKg = fmKg
        self.ffmKg = ffmKg
        super.init(timestamp: timestamp)
        
    }
}


