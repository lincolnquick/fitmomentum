//
//  NutritionMeasurement.swift
//  FitMomentum
//
//  Updated by Lincoln Quick on 12/31/24.
//

import Foundation

/// Represents the aggregated daily nutrition data.
class NutritionMeasurement: Measurement {
    
    private var entries: [NutritionEntryMeasurement] = [] // Collection of individual entries

    // Computed totals for macronutrients
    var kilocalories: Double { entries.reduce(0) { $0 + $1.kilocalories } }
    var protein: Double { entries.reduce(0) { $0 + $1.protein } }
    var carbohydrates: Double { entries.reduce(0) { $0 + $1.carbohydrates } }
    var fats: Double { entries.reduce(0) { $0 + $1.fats } }
    var dietaryFiber: Double { entries.reduce(0) { $0 + $1.dietaryFiber } }
    var netCarbohydrates: Double { entries.reduce(0) { $0 + $1.netCarbohydrates } }

    // Additional Macronutrient Details
    var saturatedFat: Double { entries.reduce(0) { $0 + $1.saturatedFat } }
    var transFat: Double { entries.reduce(0) { $0 + $1.transFat } }
    var polyunsaturatedFat: Double { entries.reduce(0) { $0 + $1.polyunsaturatedFat } }
    var monounsaturatedFat: Double { entries.reduce(0) { $0 + $1.monounsaturatedFat } }
    var sugar: Double { entries.reduce(0) { $0 + $1.sugar } }
    var addedSugars: Double { entries.reduce(0) { $0 + $1.addedSugars } }
    var sugarAlcohols: Double { entries.reduce(0) { $0 + $1.sugarAlcohols } }

    // Computed totals for micronutrients
    var cholesterol: Double { entries.reduce(0) { $0 + $1.cholesterol } }
    var sodium: Double { entries.reduce(0) { $0 + $1.sodium } }
    var potassium: Double { entries.reduce(0) { $0 + $1.potassium } }
    var calcium: Double { entries.reduce(0) { $0 + $1.calcium } }
    var iron: Double { entries.reduce(0) { $0 + $1.iron } }
    var vitaminA: Double { entries.reduce(0) { $0 + $1.vitaminA } }
    var vitaminB12: Double { entries.reduce(0) { $0 + $1.vitaminB12 } }
    var vitaminC: Double { entries.reduce(0) { $0 + $1.vitaminC } }
    var vitaminD: Double { entries.reduce(0) { $0 + $1.vitaminD } }
    var vitaminE: Double { entries.reduce(0) { $0 + $1.vitaminE } }
    var vitaminK: Double { entries.reduce(0) { $0 + $1.vitaminK } }
    var magnesium: Double { entries.reduce(0) { $0 + $1.magnesium } }
    var zinc: Double { entries.reduce(0) { $0 + $1.zinc } }
    var selenium: Double { entries.reduce(0) { $0 + $1.selenium } }
    var copper: Double { entries.reduce(0) { $0 + $1.copper } }
    var manganese: Double { entries.reduce(0) { $0 + $1.manganese } }
    var phosphorus: Double { entries.reduce(0) { $0 + $1.phosphorus } }
    var folate: Double { entries.reduce(0) { $0 + $1.folate } }
    var niacin: Double { entries.reduce(0) { $0 + $1.niacin } }
    var riboflavin: Double { entries.reduce(0) { $0 + $1.riboflavin } }
    var thiamin: Double { entries.reduce(0) { $0 + $1.thiamin } }
    var pantothenicAcid: Double { entries.reduce(0) { $0 + $1.pantothenicAcid } }
    var biotin: Double { entries.reduce(0) { $0 + $1.biotin } }
    var choline: Double { entries.reduce(0) { $0 + $1.choline } }

    required init(timestamp: Date, value: Double) {
        super.init(timestamp: timestamp, value: value)
    }

    convenience init(timestamp: Date) {
        self.init(timestamp: timestamp, value: 0.0)
    }

    /// Adds or updates an individual nutrition entry.
    /// - Parameter entry: The `NutritionEntryMeasurement` to add or update.
    func addOrUpdateEntry(_ entry: NutritionEntryMeasurement) {
        guard Calendar.current.isDate(entry.timestamp, inSameDayAs: timestamp) else {
            fatalError("Nutrition entries must match the parent NutritionMeasurement's date.")
        }
        
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
    }

    /// Removes a nutrition entry by its unique ID.
    /// - Parameter entryID: The UUID of the entry to remove.
    func removeEntry(byID entryID: UUID) {
        entries.removeAll { $0.id == entryID }
    }

    /// Retrieves all nutrition entries in the measurement.
    /// - Returns: An array of `NutritionEntryMeasurement` objects.
    func getEntries() -> [NutritionEntryMeasurement] {
        return entries
    }

    override var description: String {
        let formattedDate = timestamp.formatted(.dateTime.month(.abbreviated).day().year())
        return "NutritionMeasurement - Kilocalories: \(kilocalories), Timestamp: \(formattedDate)"
    }
    
    /// Validate that all entries are valid.
    override func validate() throws {
        try entries.forEach { try $0.validate() }
    }
}
