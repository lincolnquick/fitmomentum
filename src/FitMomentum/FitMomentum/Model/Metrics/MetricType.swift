//
//  MetricType.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//

enum MetricType: String, CaseIterable {
    case weight = "Weight"
    case trendWeight = "Trend Weight"
    case bodyFat = "Body Fat"
    case trendBodyFat = "Trend Body Fat"
    case steps = "Steps"
    case distance = "Distance"
    case activeCalories = "Active Calories"
    case caloriesConsumed = "Calories Consumed"
    case energyBalance = "Energy Balance"

    var chartType: ChartType {
        switch self {
        case .weight, .trendWeight, .bodyFat, .trendBodyFat:
            return .line
        case .steps, .distance, .activeCalories, .caloriesConsumed:
            return .bar
        case .energyBalance:
            return .hybrid
        }
    }
} 

