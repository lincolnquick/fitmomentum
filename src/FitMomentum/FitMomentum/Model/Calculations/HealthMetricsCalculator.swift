//
//  HealthMetricsCalculator.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//  References:
//  Jackson AS, Stanforth PR, Gagnon J, Rankinen T, Leon AS, Rao DC, et al. (2002). The effect of sex, age and race on estimating percentage body fat from body mass index: The Heritage Family Study. Int J Obes Relat Metab Disord. 2002; 26(6): 789-96.
//  Livingston, E. H., & Kohlstadt, I. (2005). Simplified resting metabolic rate-predicting formulas for normal-sized and obese individuals. Obesity research, 13(7), 1255–1262. https://doi.org/10.1038/oby.2005.149
//  Mifflin, M. D., St Jeor, S. T., Hill, L. A., Scott, B. J., Daugherty, S. A., & Koh, Y. O. (1990). A new predictive equation for resting energy expenditure in healthy individuals. The American Journal of Clinical Nutrition, 51(2), 241–247.

import Foundation
class HealthMetricsCalculator {
    

    /**
     `Calculates BMI defined as weight (in kg) / height (in m)^2
     - Parameters:
        - weight: Total body weight in kg
        - height: Height in centimeters
     
     - Returns
        - Calculated BMI score in kg/m2.
     Underweight: Less than 18.5; Normal Weight: 18.5-22.9; Risk to Overweight: 23-24.9; Overweight: 25-29.9; Obese Class 1: 30-39.9; Obese Class 2: 40+
     */
    static func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    /**
     Calculates Resting Metaboloic Rate (RMR) following the Livingston-Kohlstadt (2005) regression formula.
        When sex is unknown, returns the mean between male and female results.
        - Parameters:
            - weight: Total body weight in kg
            - age: Current age in years
            - sex: "male", "female", or "unkown"
        - Returns:
            - Estimated RMR in kcal/day
     */
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

        let bmi = calculateBMI(weight: bodyWeight, height: height)
        let fatMass = (bodyWeight / A) * (B * age + sexCoefficientC * log(bmi) + sexCoefficientD)
        return max(fatMass, 0)
    }
    
    /**
     Calculates Resting Metabolic Rate (RMR) using the Mifflin-St Jeor equation.
     - Parameters:
        - weight: Weight in kilograms.
        - height: Height in centimeters.
        - age: Age in years.
        - sex: Biological sex ("male", "female", or "unknown").
     - Returns: Estimated RMR in kcal/day.
     */
    static func calculateRMRMifflinStJeor(weight: Double, height: Double, age: Double, sex: String) -> Double {
        let lowercasedSex = sex.lowercased()
        switch lowercasedSex {
        case "male":
            return 10 * weight + 6.25 * height - 5 * age + 5
        case "female":
            return 10 * weight + 6.25 * height - 5 * age - 161
        default:
            let maleRMR = 10 * weight + 6.25 * height - 5 * age + 5
            let femaleRMR = 10 * weight + 6.25 * height - 5 * age - 161
            return (maleRMR + femaleRMR) / 2
        }
    }
    
    /**
     Adjusts Total Daily Energy Expenditure (TDEE) based on activity level.
         
         - Parameters:
            - rmr: Resting Metabolic Rate in kcal/day.
            - activityFactor: Activity multiplier (e.g., 1.2 for sedentary, 1.55 for moderately active).
         
         - Returns: Adjusted TDEE in kcal/day.
         
         - Throws: `ActivityFactorError` if the activity factor is out of range (1.2 to 1.9).
         */
    static func calculateTDEEWithActivityFactor(rmr: Double, activityFactor: Double) throws -> Double {
        guard (1.2...1.9).contains(activityFactor) else {
            throw ActivityFactorError.outOfRange
        }
        return rmr * activityFactor
    }
    
    /** Calculates the amount of lean body mass given the total mass and fat mass.
     - Parameters:
        -weight: Total body weight in kg
        -fat mass: Fat mass in kg
     
     - Returns: Lean mass (FFM) in kg
     
     */
    static func calculateLeanBodyMass(weight: Double, fatMass: Double) -> Double {
        return max(weight - fatMass, 0.0)
    }
    
    static func calculateBodyFatPercentage(weight: Double, fatMass: Double) -> Double {
        return (fatMass / weight) * 100.0
    }
    
    static func calculateCaloricImbalance(intake: Double, tdee: Double) -> Double {
        return intake - tdee
    }
    
    static func calculateMacronutrientCalories(protein: Double, carbs: Double, fats: Double) -> (protein: Double, carbs: Double, fats: Double) {
        let proteinCalories = abs(protein) * 4
        let carbCalories = abs(carbs) * 4
        let fatCalories = abs(fats) * 9
        return (proteinCalories, carbCalories, fatCalories)
    }
    
    static func estimateDaysToGoal(targetWeight: Double, currentWeight: Double, weightChangeRate: Double) -> Int {
        guard weightChangeRate != 0 else { return Int.max }
        let days = (targetWeight - currentWeight) / weightChangeRate
        return max(Int(ceil(days)), 0)
    }
}

    /// Custom error type for invalid activity factors.
enum ActivityFactorError: Error, CustomStringConvertible {
        case outOfRange
        
        var description: String {
            switch self {
            case .outOfRange:
                return "Activity factor must be between 1.2 and 1.9."
            }
        }
}

