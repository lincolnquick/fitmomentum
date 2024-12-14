//
//  WeightEntry.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/13/24.
//

import Foundation


struct WeightEntry: Identifiable {
    let id = UUID()
    let date: String // Example: "Dec 8"
    let weight: Double
}

// Sample weightEntries for Recent Weight Trends Card
let recentWeightData: [WeightEntry] = [
    WeightEntry(date: "Dec 7", weight: 175.2),
    WeightEntry(date: "Dec 8", weight: 174.8),
    WeightEntry(date: "Dec 9", weight: 174.5),
    WeightEntry(date: "Dec 10", weight: 174.0),
    WeightEntry(date: "Dec 11", weight: 173.8),
    WeightEntry(date: "Dec 12", weight: 173.6),
    WeightEntry(date: "Dec 13", weight: 173.4)
]
