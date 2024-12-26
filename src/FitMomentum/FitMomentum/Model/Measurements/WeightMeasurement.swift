//
//  WeightMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class WeightMeasurement: Measurement {
    var weight: Double // in kg
    
    init(weight: Double, timestamp: Date = Date()) {
        self.weight = weight
        super.init(timestamp: timestamp)
    }
}
