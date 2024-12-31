//
//  NutritionMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class NutritionMeasurement: Measurement {
    private var entries: [NutritionEntryMeasurement] = []

    /// Calculated totals for macronutrients and micronutrients.
    var protein: Double { entries.reduce(0) { $0 + $1.protein } }
    var carbohydrates: Double { entries.reduce(0) { $0 + $1.carbohydrates } }
    var fats: Double { entries.reduce(0) { $0 + $1.fats } }
    var dietaryFiber: Double { entries.reduce(0) { $0 + $1.dietaryFiber } }
    var sodium: Double { entries.reduce(0) { $0 + $1.sodium } }
    var potassium: Double { entries.reduce(0) { $0 + $1.potassium } }
    var kilocalories: Double { entries.reduce(0) { $0 + $1.value } }

    required init(
        timestamp: Date,
        value: Double
    ) {
        super.init(timestamp: timestamp, value: value)
    }

    convenience init(
        timestamp: Date
    ) {
        self.init(timestamp: timestamp, value: 0.0)
    }

    /// Add or update a nutrition entry. If an entry with the same ID exists, update it.
    /// - Parameter entry: The nutrition entry to add or update.
    func addOrUpdateEntry(_ entry: NutritionEntryMeasurement) {
        guard Calendar.current.isDate(entry.timestamp, inSameDayAs: timestamp) else {
            fatalError("Nutrition entries must have the same date as their parent NutritionMeasurement.")
        }

        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
    }

    /// Remove a nutrition entry.
    /// - Parameter entryID: The unique ID of the entry to remove.
    func removeEntry(byID entryID: UUID) {
        entries.removeAll { $0.id == entryID }
    }

    /// Retrieve all nutrition entries.
    /// - Returns: An array of `NutritionEntryMeasurement` objects.
    func getEntries() -> [NutritionEntryMeasurement] {
        return entries
    }

    /// Validate that all entries are valid.
    override func validate() throws {
        try entries.forEach { try $0.validate() }
    }
}
