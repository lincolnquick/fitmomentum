//
//  HeymsfieldModelCalculator.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//
import Foundation

class HeymsfieldModelCalculator {
    private let user: User
    private let intakeCollection: MeasurementCollection<NutritionMeasurement> // Collection for daily energy intake
    private let weightCollection: MeasurementCollection<WeightMeasurement> // Collection for weight measurements
    
    init(user: User, intakeCollection: MeasurementCollection<NutritionMeasurement>, weightCollection: MeasurementCollection<WeightMeasurement>) {
        self.user = user
        self.intakeCollection = intakeCollection
        self.weightCollection = weightCollection
    }
    
    // Baseline energy expenditure
    func calculateBaselineExpenditure() -> Double {
        let weight = weightCollection.getEarliestMeasurement()?.weight ?? 0
        var baselineExpenditure: Double = 0.0
        switch user.sex {
        case "male":
            baselineExpenditure = -0.0971 * pow(weight,2) + 40.853 * weight + 323.59
        case "female":
            baselineExpenditure = 0.0278 * pow(weight,2) + 9.2893 * weight + 1528.9
        default:
            let maleBaseline = -0.0971 * pow(weight,2) + 40.853 * weight + 323.59
            let femaleBaseline = 0.0278 * pow(weight,2) + 9.2893 * weight + 1528.9
            baselineExpenditure = (maleBaseline + femaleBaseline) / 2.0
        }
        return baselineExpenditure
    }
    
    // Baseline RMR
    func calculateBaselineRMR() -> Double {
        let weight = weightCollection.getEarliestMeasurement()?.weight ?? 0
        return HealthMetricsCalculator.calculateRMR(
            weight: weight,
            age: user.age,
            sex: user.sex
        )
    }

    // Baseline DIT
    func calculateDIT(forIntake intake: Double) -> Double {
        let beta = 0.075 // Default for caloric restriction
        return beta * intake
    }
    
    // Baseline SPA
    func calculateSPA(forTotalExpenditure expenditure: Double) -> Double {
        return 0.326 * expenditure // Default SPA fraction
    }
    
    // Baseline PA
    func calculatePA(forTotalExpenditure expenditure: Double, rmr: Double, dit: Double, spa: Double) -> Double {
        let remaining = expenditure - (rmr + dit + spa)
        return max(remaining, 0) // Ensure PA is non-negative
    }
    
    // Total Energy Expenditure (TEE)
    func calculateTEE(rmr: Double, dit: Double, pa: Double, spa: Double) -> Double {
        return rmr + dit + pa + spa
    }
    
    // TODO: Calculate energy balance and weight changes over time

}
