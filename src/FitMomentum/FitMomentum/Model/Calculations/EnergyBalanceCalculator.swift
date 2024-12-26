//
//  EnergyBalanceCalculator.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//
import Foundation
import Accelerate

/// Calculator for energy balance metrics and analysis.
class EnergyBalanceCalculator {
    
    private let person: Person
    
    init(person: Person) {
        self.person = person
    }
    
    /**
     Calculates the energy balance metrics over time.
     
     - Parameters:
        - weights: Array of weight measurements.
        - intakes: Array of nutrition measurements.
        - bodyFatMeasurements: Optional array of body fat measurements.
     
     - Returns: Array of energy balance results.
     */
    func calculateEnergyBalance(
        weights: [WeightMeasurement],
        intakes: [NutritionMeasurement],
        bodyFatMeasurements: [BodyFatMeasurement] = []
    ) -> [EnergyBalanceResult] {
        validateInputData(weights: weights, intakes: intakes)
        let initialBodyFatPercentage = determineInitialBodyFatPercentage(
            weights: weights,
            bodyFatMeasurements: bodyFatMeasurements
        )
        
        return computeEnergyBalance(
            weights: weights,
            intakes: intakes,
            initialBodyFatPercentage: initialBodyFatPercentage
        )
    }
    
    /// Ensures input data validity.
    private func validateInputData(weights: [WeightMeasurement], intakes: [NutritionMeasurement]) {
        guard !weights.isEmpty, !intakes.isEmpty else {
            fatalError("Weight and intake collections must not be empty.")
        }
        
        let sortedWeights = weights.sorted { $0.timestamp < $1.timestamp }
        let sortedIntakes = intakes.sorted { $0.timestamp < $1.timestamp }
        
        guard sortedWeights.count == sortedIntakes.count,
              sortedWeights.map({ $0.timestamp }) == sortedIntakes.map({ $0.timestamp }) else {
            fatalError("Weight and intake collections must have matching timestamps.")
        }
    }
    
    /// Determines the initial body fat percentage using measurements or estimation.
    private func determineInitialBodyFatPercentage(
        weights: [WeightMeasurement],
        bodyFatMeasurements: [BodyFatMeasurement]
    ) -> Double {
        if !bodyFatMeasurements.isEmpty {
            let sortedMeasurements = bodyFatMeasurements.sorted { $0.timestamp < $1.timestamp }
            let values = sortedMeasurements.prefix(3).map { $0.bodyFatPercentage }
            return values.median()
        } else {
            let initialWeight = weights.first!.weight
            let initialAge = person.getAge(asOf: weights.first!.timestamp)
            return HealthMetricsCalculator.estimateInitialFatMass(
                sex: person.sex,
                age: initialAge,
                bodyWeight: initialWeight,
                height: person.height
            ) / initialWeight
        }
    }
    
    /// Computes energy balance metrics for each measurement.
    private func computeEnergyBalance(
        weights: [WeightMeasurement],
        intakes: [NutritionMeasurement],
        initialBodyFatPercentage: Double
    ) -> [EnergyBalanceResult] {
        var results: [EnergyBalanceResult] = []
        
        for i in 0..<weights.count {
            let weight = weights[i].weight
            let intake = intakes[i].kilocalories
            let date = weights[i].timestamp
            
            let age = person.getAge(asOf: date)
            let rmr = HealthMetricsCalculator.calculateRMR(weight: weight, age: age, sex: person.sex)
            let fm = weight * initialBodyFatPercentage
            let ffm = weight - fm
            let deltaBW = i > 0 ? weight - weights[i - 1].weight : 0.0
            let deltaFFM = calculateDeltaFFM(fmInitial: fm, deltaBW: deltaBW)
            let deltaFM = deltaBW - deltaFFM
            let energyImbalance = calculateEnergyImbalance(deltaFFM: deltaFFM, deltaFM: deltaFM)
            let tee = intake - energyImbalance
            
            results.append(EnergyBalanceResult(
                rmrKcal: rmr,
                teeKcal: tee,
                fmKg: fm,
                ffmKg: ffm,
                timestamp: date
            ))
        }
        
        return results
    }
    
    /// Calculates the change in fat-free mass using Forbes Equation 7.
    private func calculateDeltaFFM(fmInitial: Double, deltaBW: Double) -> Double {
        let exponent = (deltaBW / 10.4) + (fmInitial / 10.4)
        let argument = (1 / 10.4) * exp(exponent) * fmInitial
        let lambertResult = lambertW(argument)
        let fmFinal = 10.4 * lambertResult
        return (fmInitial + deltaBW) - fmFinal
    }
    
    /// Calculates energy imbalance based on changes in FFM and FM.
    private func calculateEnergyImbalance(deltaFFM: Double, deltaFM: Double) -> Double {
        return 9.05 * deltaFM + 1 * deltaFFM
    }
    
    /// Approximates the Lambert W function for a given input `x`.
    /// - Parameters:
    ///   - x: The input value (must be >= 0).
    ///   - iterations: The number of iterations for the Newton-Raphson method (default: 10).
    /// - Returns: An approximation of the Lambert W function at `x`.
    private func lambertW(_ x: Double, iterations: Int = 10) -> Double {
        guard x >= 0 else { fatalError("Lambert W is not defined for negative values.") }
        
        // Initial guess for W
        var w = log(1 + x)
        
        // Newton-Raphson iteration
        for _ in 0..<iterations {
            let ew = exp(w) // e^w
            let wNext = w - (w * ew - x) / (ew * (w + 1) - ((w + 2) * (w * ew - x)) / (2 * (w + 1)))
            if abs(wNext - w) < 1e-10 { break } // Convergence check
            w = wNext
        }
        
        return w
    }
}

extension Array where Element == Double {
    /// Calculates the median of an array of doubles.
    func median() -> Double {
        let sorted = self.sorted()
        let count = sorted.count
        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2
        } else {
            return sorted[count / 2]
        }
    }
}
