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
    var activityMeasurements: MeasurementCollection<ActivityMeasurement>
    var weightTrends: TrendMeasurementCollection<TrendWeightMeasurement>
    var bodyFatTrends: TrendMeasurementCollection<TrendBodyFatMeasurement>
    var energyBalanceResults: TrendMeasurementCollection<EnergyBalanceResult>
    
    init(
        person: Person,
        preferences: UserPreferences,
        weightGoals: [WeightGoal] = [],
        weightMeasurements: MeasurementCollection<WeightMeasurement> = MeasurementCollection(),
        bodyFatMeasurements: MeasurementCollection<BodyFatMeasurement> = MeasurementCollection(),
        nutritionMeasurements: MeasurementCollection<NutritionMeasurement> = MeasurementCollection(),
        activityMeasurements: MeasurementCollection<ActivityMeasurement> = MeasurementCollection(),
        weightTrends: TrendMeasurementCollection<TrendWeightMeasurement> = TrendMeasurementCollection(),
        bodyFatTrends: TrendMeasurementCollection<TrendBodyFatMeasurement> = TrendMeasurementCollection(),
        energyBalanceResults: TrendMeasurementCollection<EnergyBalanceResult> = TrendMeasurementCollection()
    ){
        self.person = person
        self.preferences = preferences
        self.weightGoals = weightGoals
        self.weightMeasurements = weightMeasurements
        self.bodyFatMeasurements = bodyFatMeasurements
        self.nutritionMeasurements = nutritionMeasurements
        self.activityMeasurements = activityMeasurements
        self.weightTrends = weightTrends
        self.bodyFatTrends = bodyFatTrends
        self.energyBalanceResults = energyBalanceResults
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
    
    // Treat the most recent weight goal as the current
    var currentWeightGoal: WeightGoal {
        return weightGoals.last!
    }
    
}
