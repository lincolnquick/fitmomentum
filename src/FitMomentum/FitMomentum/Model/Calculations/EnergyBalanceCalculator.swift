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
        - weights: A `MeasurementCollection` of weight measurements.
        - intakes: A `MeasurementCollection` of nutrition measurements.
        - bodyFatMeasurements: Optional `MeasurementCollection` of body fat measurements.
     
     - Returns: A `MeasurementCollection` of energy balance results.
     */
    func calculateEnergyBalance(
        weights: MeasurementCollection<WeightMeasurement>,
        intakes: MeasurementCollection<NutritionMeasurement>,
        bodyFatMeasurements: MeasurementCollection<BodyFatMeasurement>? = nil
    ) -> MeasurementCollection<EnergyBalanceResult> {
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
    private func validateInputData(
        weights: MeasurementCollection<WeightMeasurement>,
        intakes: MeasurementCollection<NutritionMeasurement>
    ) {
        guard !weights.isEmpty, !intakes.isEmpty else {
            fatalError("Weight and intake collections must not be empty.")
        }
        
        let weightDates = weights.getAllMeasurements().map { $0.timestamp }
        let intakeDates = intakes.getAllMeasurements().map { $0.timestamp }
        
        guard weightDates == intakeDates else {
            fatalError("Weight and intake collections must have matching timestamps.")
        }
    }
    
    /// Determines the initial body fat percentage using measurements or estimation.
    private func determineInitialBodyFatPercentage(
        weights: MeasurementCollection<WeightMeasurement>,
        bodyFatMeasurements: MeasurementCollection<BodyFatMeasurement>?
    ) -> Double {
        if let bodyFatMeasurements = bodyFatMeasurements, !bodyFatMeasurements.isEmpty {
            let sortedMeasurements = bodyFatMeasurements.getAllMeasurements()
            let values = sortedMeasurements.prefix(3).map { $0.bodyFatPercentage }
            return values.median()
        } else {
            guard let initialWeight = weights.getAllMeasurements().first?.weight else {
                fatalError("No weight measurements available.")
            }
            let initialAge = person.getAge(asOf: weights.getAllMeasurements().first!.timestamp)
            return HealthMetricsCalculator.estimateInitialFatMass(
                sex: person.sex,
                age: initialAge,
                bodyWeight: initialWeight,
                height: person.height
            ) / initialWeight
        }
    }
    
    /// Computes energy balance metrics for each measurement and returns them as a `MeasurementCollection`.
    private func computeEnergyBalance(
        weights: MeasurementCollection<WeightMeasurement>,
        intakes: MeasurementCollection<NutritionMeasurement>,
        initialBodyFatPercentage: Double
    ) -> MeasurementCollection<EnergyBalanceResult> {
        let energyBalanceCollection = MeasurementCollection<EnergyBalanceResult>()
        let weightMeasurements = weights.getAllMeasurements()
        let intakeMeasurements = intakes.getAllMeasurements()
        
        for i in 0..<weightMeasurements.count {
            let weight = weightMeasurements[i].weight
            let intake = intakeMeasurements[i].kilocalories
            let date = weightMeasurements[i].timestamp
            
            let age = person.getAge(asOf: date)
            let rmr = HealthMetricsCalculator.calculateRMR(weight: weight, age: age, sex: person.sex)
            let fm = weight * initialBodyFatPercentage
            let ffm = weight - fm
            let deltaBW = i > 0 ? weight - weightMeasurements[i - 1].weight : 0.0
            let deltaFFM = calculateDeltaFFM(fmInitial: fm, deltaBW: deltaBW)
            let deltaFM = deltaBW - deltaFFM
            let energyImbalance = calculateEnergyImbalance(deltaFFM: deltaFFM, deltaFM: deltaFM)
            let tee = intake - energyImbalance
            
            let result = EnergyBalanceResult(
                hasRecordedMeasurement: false,
                calculationMethod: "Forbes Model",
                calculatedAt: Date(),
                timestamp: date,
                teeKcal: tee,
                rmrKcal: rmr,
                fmKg: fm,
                ffmKg: ffm
            )
            do {
                try energyBalanceCollection.addOrUpdateMeasurement(result)
            } catch {
                print("Failed to add or update measurement \(result): on date \(date)\n) Error: \(error.localizedDescription)")
            }
            
        }
    
        return energyBalanceCollection
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
    
    /**
         Calculates the required caloric deficit or surplus for a target weight change using Hall's modified Forbes equation.
         
         - Parameters:
            - initialWeight: Starting weight in kilograms.
            - targetWeight: Target weight in kilograms.
            - initialBodyFat: Optional initial body fat in kilograms. If not provided, it is estimated.
         - Returns: The daily caloric deficit or surplus required (kcal/day).
         */
        func calculateCaloricImbalanceForWeightChange(
            initialWeight: Double,
            targetWeight: Double,
            weightGoalStrategy: WeightGoalStrategy,
            initialBodyFat: Double? = nil
        ) -> Double {
            // Estimate body fat if not provided
            let bodyFat = initialBodyFat ?? estimateInitialBodyFat(initialWeight: initialWeight)

            // Calculate the energy densities of fat mass (FM) and lean body mass (LBM)
            let rhoF = 39.5 // MJ/kg for fat mass
            let rhoL = 7.6  // MJ/kg for lean body mass

            // Calculate the proportion of lean body mass lost using Hall's modification of Forbes' equation
            let deltaBW = targetWeight - initialWeight
            let deltaLDivDeltaBW = calculateLeanMassProportionChange(deltaBW: deltaBW, bodyFat: bodyFat)

            // Calculate the energy density of weight change
            let energyDensity = rhoF + (rhoL - rhoF) * deltaLDivDeltaBW // MJ/kg

            // Convert energy density to kcal/kg and calculate daily caloric imbalance
            let energyDensityKcal = energyDensity * 239.00573614 // MJ/kg to kcal/kg
            let totalCaloricImbalance = deltaBW * energyDensityKcal
            let daysToAchieve = abs(deltaBW / (initialWeight * weightGoalStrategy.bodyWeightChangeRate / 7.0))
            return totalCaloricImbalance / daysToAchieve
        }
    
    /**
         Estimates the initial body fat based on the person's parameters.
         - Parameters:
            - initialWeight: Starting weight in kilograms.
         - Returns: Estimated body fat in kilograms.
         */
        private func estimateInitialBodyFat(initialWeight: Double) -> Double {
            let age = person.getAge()
            return HealthMetricsCalculator.estimateInitialFatMass(
                sex: person.sex,
                age: age,
                bodyWeight: initialWeight,
                height: person.height
            )
        }

        /**
         Calculates the proportion of lean mass lost during weight change.
         - Parameters:
            - deltaBW: Change in body weight (kg).
            - bodyFat: Initial body fat (kg).
         - Returns: The proportion of lean mass lost.
         */
        private func calculateLeanMassProportionChange(deltaBW: Double, bodyFat: Double) -> Double {
            let fi = bodyFat
            let argument = (1 / 10.4) * exp((deltaBW / 10.4) + (fi / 10.4)) * fi
            let lambertResult = lambertW(argument)
            let deltaLDivDeltaBW = 1 + (fi / deltaBW) - (10.4 / deltaBW) * lambertResult
            return deltaLDivDeltaBW
        }

    
    func calculateEnergyDensityOfWeightLoss(
        initialBodyFat: Double,
        weightLoss: Double
    ) -> Double {
        let rhoF = 39.5 // MJ/kg for fat
        let rhoL = 7.6  // MJ/kg for lean mass
        let deltaL = (1 + (initialBodyFat / weightLoss) - (10.4 / weightLoss)) *
                     exp(weightLoss / 10.4) * initialBodyFat *
                     exp(initialBodyFat / 10.4)
        let proportionLean = deltaL / weightLoss
        return rhoF + (rhoL - rhoF) * proportionLean
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
