//
//  HealthMetricsCalculator.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//
import Foundation
class HealthMetricsCalculator {
    static func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
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
}
