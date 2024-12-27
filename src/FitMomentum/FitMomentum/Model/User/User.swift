//
//  User.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/26/24.
//
import Foundation

/// Represents a user including their characteristics (Person: sex, dob, height), preferences, weight goals, and a collection of their measurements
class User {
    var person: Person
    var preferences: UserPreferences
    var weightGoals: [WeightGoal]
    var weightMeasurements: MeasurementCollection<WeightMeasurement>
    var bodyFatMeasurements: MeasurementCollection<BodyFatMeasurement>
    var nutritionMeasurements: MeasurementCollection<NutritionMeasurement>
    
    init(
        person: Person,
        preferences: UserPreferences,
        weightGoals: [WeightGoal] = [],
        weightMeasurements: MeasurementCollection<WeightMeasurement> = MeasurementCollection(),
        bodyFatMeasurements: MeasurementCollection<BodyFatMeasurement> = MeasurementCollection(),
        nutritionMeasurements: MeasurementCollection<NutritionMeasurement> = MeasurementCollection()
    ){
        self.person = person
        self.preferences = preferences
        self.weightGoals = weightGoals
        self.weightMeasurements = weightMeasurements
        self.bodyFatMeasurements = bodyFatMeasurements
        self.nutritionMeasurements = nutritionMeasurements
    }
    
    var mostRecentWeight: Double? {
        return weightMeasurements.getMostRecentMeasurement()?.weight
    }
    
    var mostRecentBodyFatPercentage: Double? {
        return bodyFatMeasurements.getMostRecentMeasurement()?.bodyFatPercentage
    }
    
    var age: Double {
        return person.getAge()
    }
    
    var sex: String {
        return person.sex
    }
    
    var height: Double {
        return person.height
    }
}
