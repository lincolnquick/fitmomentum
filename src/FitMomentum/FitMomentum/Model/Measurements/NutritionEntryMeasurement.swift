import Foundation

/// Represents an entry in a daily nutrition log.
class NutritionEntryMeasurement: Measurement {
    
    var kilocalories: Double
    // Macronutrients
    var protein: Double // in grams
    var carbohydrates: Double // in grams
    var fats: Double // in grams
    var dietaryFiber: Double // in grams
    var netCarbohydrates: Double { carbohydrates - dietaryFiber - sugarAlcohols} // Computed property for net carbs
    
    // Additional Macronutrient Details
    // Fats
    var saturatedFat: Double // in grams
    var transFat: Double // in grams
    var polyunsaturatedFat: Double // in grams
    var monounsaturatedFat: Double // in grams
    // Carbs
    var sugar: Double // in grams
    var addedSugars: Double // in grams
    var sugarAlcohols: Double // in grams
    
    // Micronutrients
    var cholesterol: Double // in milligrams
    var sodium: Double // in milligrams
    var potassium: Double // in milligrams
    var calcium: Double // in milligrams
    var iron: Double // in milligrams
    var vitaminA: Double // in micrograms
    var vitaminC: Double // in milligrams
    var vitaminD: Double // in micrograms
    var vitaminE: Double // in milligrams
    var vitaminK: Double // in micrograms
    var magnesium: Double // in milligrams
    var zinc: Double // in milligrams
    var selenium: Double // in micrograms
    var copper: Double // in milligrams
    var manganese: Double // in milligrams
    var phosphorus: Double // in milligrams
    var folate: Double // in micrograms
    var niacin: Double // in milligrams
    var riboflavin: Double // in milligrams
    var thiamin: Double // in milligrams
    var pantothenicAcid: Double // in milligrams
    var biotin: Double // in micrograms
    var choline: Double // in milligrams

    // Metadata
    var id: UUID // Unique identifier for the entry
    var name: String? // Optional name for the entry
    var description: String? // Optional description for the entry
    var meal: MealType? // Meal type (e.g., breakfast, lunch, etc.)

    enum MealType: String {
        case breakfast
        case lunch
        case dinner
        case snack
    }

    required init(timestamp: Date, value: Double) {
        self.kilocalories = value
        self.protein = 0.0
        self.carbohydrates = 0.0
        self.fats = 0.0
        self.dietaryFiber = 0.0
        self.saturatedFat = 0.0
        self.transFat = 0.0
        self.polyunsaturatedFat = 0.0
        self.monounsaturatedFat = 0.0
        self.cholesterol = 0.0
        self.sugar = 0.0
        self.addedSugars = 0.0
        self.sugarAlcohols = 0.0
        self.sodium = 0.0
        self.potassium = 0.0
        self.calcium = 0.0
        self.iron = 0.0
        self.vitaminA = 0.0
        self.vitaminC = 0.0
        self.vitaminD = 0.0
        self.vitaminE = 0.0
        self.vitaminK = 0.0
        self.magnesium = 0.0
        self.zinc = 0.0
        self.selenium = 0.0
        self.copper = 0.0
        self.manganese = 0.0
        self.phosphorus = 0.0
        self.folate = 0.0
        self.niacin = 0.0
        self.riboflavin = 0.0
        self.thiamin = 0.0
        self.pantothenicAcid = 0.0
        self.biotin = 0.0
        self.choline = 0.0
        self.id = UUID()
        super.init(timestamp: timestamp, value: value)
    }

    convenience init(
        timestamp: Date,
        kilocalories: Double,
        protein: Double = 0.0,
        carbohydrates: Double = 0.0,
        fats: Double = 0.0,
        dietaryFiber: Double = 0.0,
        saturatedFat: Double = 0.0,
        transFat: Double = 0.0,
        polyunsaturatedFat: Double = 0.0,
        monounsaturatedFat: Double = 0.0,
        cholesterol: Double = 0.0,
        sugar: Double = 0.0,
        addedSugars: Double = 0.0,
        sugarAlcohols: Double = 0.0,
        sodium: Double = 0.0,
        potassium: Double = 0.0,
        calcium: Double = 0.0,
        iron: Double = 0.0,
        vitaminA: Double = 0.0,
        vitaminC: Double = 0.0,
        vitaminD: Double = 0.0,
        vitaminE: Double = 0.0,
        vitaminK: Double = 0.0,
        magnesium: Double = 0.0,
        zinc: Double = 0.0,
        selenium: Double = 0.0,
        copper: Double = 0.0,
        manganese: Double = 0.0,
        phosphorus: Double = 0.0,
        folate: Double = 0.0,
        niacin: Double = 0.0,
        riboflavin: Double = 0.0,
        thiamin: Double = 0.0,
        pantothenicAcid: Double = 0.0,
        biotin: Double = 0.0,
        choline: Double = 0.0,
        name: String? = nil,
        description: String? = nil,
        meal: MealType? = nil
    ) {
        self.init(timestamp: timestamp, value: kilocalories)
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
        self.dietaryFiber = dietaryFiber
        self.saturatedFat = saturatedFat
        self.transFat = transFat
        self.polyunsaturatedFat = polyunsaturatedFat
        self.monounsaturatedFat = monounsaturatedFat
        self.cholesterol = cholesterol
        self.sugar = sugar
        self.addedSugars = addedSugars
        self.sugarAlcohols = sugarAlcohols
        self.sodium = sodium
        self.potassium = potassium
        self.calcium = calcium
        self.iron = iron
        self.vitaminA = vitaminA
        self.vitaminC = vitaminC
        self.vitaminD = vitaminD
        self.vitaminE = vitaminE
        self.vitaminK = vitaminK
        self.magnesium = magnesium
        self.zinc = zinc
        self.selenium = selenium
        self.copper = copper
        self.manganese = manganese
        self.phosphorus = phosphorus
        self.folate = folate
        self.niacin = niacin
        self.riboflavin = riboflavin
        self.thiamin = thiamin
        self.pantothenicAcid = pantothenicAcid
        self.biotin = biotin
        self.choline = choline
        self.name = name
        self.description = description
        self.meal = meal
    }

    /// Validate that all nutrition values are non-negative.
    override func validate() throws {
        let properties = [
            protein, carbohydrates, fats, dietaryFiber, saturatedFat, transFat,
            polyunsaturatedFat, monounsaturatedFat, cholesterol, sugar, addedSugars,
            sugarAlcohols, sodium, potassium, calcium, iron, vitaminA, vitaminC,
            vitaminD, vitaminE, vitaminK, magnesium, zinc, selenium, copper,
            manganese, phosphorus, folate, niacin, riboflavin, thiamin,
            pantothenicAcid, biotin, choline
        ]
        guard properties.allSatisfy({ $0 >= 0 }) else {
            throw MeasurementError.invalidValue("All nutrition values must be non-negative.")
        }
    }
}
