//
//  HealthMetricsCalculator.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//  References:
//  Jackson AS, Stanforth PR, Gagnon J, Rankinen T, Leon AS, Rao DC, et al. (2002). The
//    effect of sex, age and race on estimating percentage body fat from body mass index: The
//    Heritage Family Study. Int J Obes Relat Metab Disord. 2002; 26(6): 789-96.
//  Livingston, E. H., & Kohlstadt, I. (2005). Simplified resting metabolic rate-predicting
//    formulas for normal-sized and obese individuals. Obesity research, 13(7), 1255–1262.
//    https://doi.org/10.1038/oby.2005.149
//
import Foundation
class HealthMetricsCalculator {
    /// Calculates BMI defined as weight (in kg) / height (in m)^2
    static func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    /// Calculates Resting Metabolic Rate or RMR in kilocalories per day (Livingston & Kohlstadt, 2005).
    static func calculateRMR(weight: Double, age: Double, sex: String) -> Double {
        let lowercasedSex = sex.lowercased()
        switch lowercasedSex {
        case "male":
            return calcRMR(weight: weight, age: age, c: 293.0, p: 0.433, y: 5.92)
        case "female":
            return calcRMR(weight: weight, age: age, c: 248.0, p: 0.4356, y: 5.09)
        default:
            let maleRMR = calcRMR(weight: weight, age: age, c: 293.0, p: 0.433, y: 5.92)
            let femaleRMR = calcRMR(weight: weight, age: age, c: 248.0, p: 0.4356, y: 5.09)
            return (maleRMR + femaleRMR) / 2
        }
    }
    
    private static func calcRMR(weight: Double, age: Double, c: Double, p: Double, y: Double) -> Double {
        let validWeight = max(weight, 0.0)
        let validAge = max(age, 0.0)
        let rmr = c * (pow(validWeight,p)) - y * validAge
        return max(rmr, 0.0)
    }
    
/**
     Estimates initial fat mass based on sex, age, body weight, and height using the Jackson et al. (2002) formula.
     
     - Parameters:
        - sex: Biological sex ("male", "female", or "unknown").
        - age: Age in years.
        - bodyWeight: Total body weight in kilograms.
        - height: Height in centimeters.
     
     - Returns: Estimated fat mass in kilograms.
     */
    static func estimateInitialFatMass(
        sex: String,
        age: Double,
        bodyWeight: Double,
        height: Double
    ) -> Double {
        let A: Double = 100.0
        let B: Double = 0.14
        let C: [String: Double] = ["male": 37.31, "female": 39.96, "unknown": 38.64]
        let D: [String: Double] = ["male": -103.94, "female": -102.01, "unknown": -102.98]

        guard let sexCoefficientC = C[sex.lowercased()], let sexCoefficientD = D[sex.lowercased()] else {
            fatalError("Invalid sex provided. Must be 'male', 'female', or 'unknown'.")
        }

        let bmi = bodyWeight / pow(height / 100.0, 2)
        let fatMass = (bodyWeight / A) * (B * age + sexCoefficientC * log(bmi) + sexCoefficientD)
        return max(fatMass, 0)
    }
}
