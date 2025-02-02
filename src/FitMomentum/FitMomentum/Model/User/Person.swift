//
//  Person.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation

/// Represents a person's generally immutable characteristics (sex, dob, height)
class Person {
    var sex: String // "male", "female", or "unknown"
    var dateOfBirth: Date
    var height: Double // in cm
    
    init(sex: String = "unknown",
         dateOfBirth: Date = Date(timeIntervalSince1970: 0),
         height: Double = 150.0) {
        self.sex = sex.lowercased() == "male" || sex.lowercased() == "female" ? sex : "unknown"
        self.dateOfBirth = dateOfBirth
        self.height = max(height, 0) // Ensures height is always positive
    }
    
    func getAge(asOf date: Date = Date()) -> Double {
        let totalDays = Calendar.current.dateComponents([.day], from: dateOfBirth, to: date).day ?? 0
        let daysPerYear = 365.2425
        return Double(totalDays) / daysPerYear
    }
}
