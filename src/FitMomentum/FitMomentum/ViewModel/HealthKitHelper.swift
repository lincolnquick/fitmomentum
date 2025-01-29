//
//  HealthKitHelper.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//

import Foundation
import HealthKit

class HealthKitHelper {
    private let healthStore: HKHealthStore
    private let user: User

    init(healthStore: HKHealthStore, user: User) {
        self.healthStore = healthStore
        self.user = user
    }

    // MARK: - HealthKit Authorization
    func requestHealthKitAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("[HealthKitHelper] HealthKit is not available on this device.")
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        // Add nutrition-related HealthKit data types
        let nutritionTypes: [HKQuantityTypeIdentifier] = [
            .dietaryEnergyConsumed,
            .dietaryCarbohydrates,
            .dietaryFatTotal,
            .dietaryProtein,
            .dietaryFiber,
            .dietarySugar,
            .dietarySodium,
            .dietaryCholesterol,
            .dietaryFatSaturated,
            .dietaryFatMonounsaturated,
            .dietaryFatPolyunsaturated,
            .dietaryPotassium,
            .dietaryCalcium,
            .dietaryIron,
            .dietaryZinc,
            .dietaryCopper,
            .dietaryFolate,
            .dietaryIodine,
            .dietaryNiacin,
            .dietaryThiamin,
            .dietaryCaffeine,
            .dietaryChloride,
            .dietaryChromium,
            .dietarySelenium,
            .dietaryMagnesium,
            .dietaryManganese,
            .dietaryBiotin,
            .dietaryMolybdenum,
            .dietaryPhosphorus,
            .dietaryRiboflavin,
            .dietaryWater,
            .dietaryVitaminA,
            .dietaryVitaminC,
            .dietaryVitaminD,
            .dietaryVitaminE,
            .dietaryVitaminK,
            .dietaryVitaminB6,
            .dietaryVitaminB12
        ]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[HealthKitHelper] Authorization Error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }

    // MARK: - Fetch Person Data (Date of Birth, Gender, Height)
    func fetchPersonData() {
        do {
            let dobComponents = try healthStore.dateOfBirthComponents()
            if let dob = Calendar.current.date(from: dobComponents) {
                user.person.dateOfBirth = dob
                print("[HealthKitHelper] Fetched Date of Birth as \(dob)")
            }

            if user.person.sex == "unknown" {
                let biologicalSex = try healthStore.biologicalSex().biologicalSex
                user.person.sex = biologicalSex.stringValue
                print("[HealthKitHelper] Fetched Gender as \(user.person.sex)")
            }

            fetchMostRecentHeight()
        } catch {
            print("[HealthKitHelper] Error fetching Person Data: \(error.localizedDescription)")
        }
    }

    private func fetchMostRecentHeight() {

        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            if let sample = results?.first as? HKQuantitySample {
                self.user.person.height = sample.quantity.doubleValue(for: .meter()) * 100.0
                print("[HealthKitHelper] Fetched Height as: \(self.user.person.height)")
            } else if let error = error {
                print("[HealthKitHelper] Error fetching Height: \(error.localizedDescription)")
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Fetch Weight Measurements
    func fetchWeightMeasurements() {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, results, error in
            guard let samples = results as? [HKQuantitySample] else {
                if let error = error {
                    print("[HealthKitHelper] Error fetching Weight Measurements: \(error.localizedDescription)")
                }
                return
            }

            DispatchQueue.main.async {
                for sample in samples {
                    do {
                        let measurement = try WeightMeasurement(timestamp: sample.startDate, weight: sample.quantity.doubleValue(for: .gramUnit(with: .kilo)))
                        try self.user.weightMeasurements.addOrUpdateMeasurement(measurement)
                    } catch {
                        print("[HealthKitHelper] Error saving Weight Measurement: \(error.localizedDescription)")
                    }
                }
                let mostRecentWeight = self.user.weightMeasurements.getMostRecentMeasurement()
                let firstWeight = self.user.weightMeasurements.getEarliestMeasurement()
                
                print("[HealthKitHelper] Fetched Weight Measurements.")
                print("[HealthKitHelper] Most Recent Weight: \(mostRecentWeight?.description)")
                print("[HealthKitHelper] Earliest Weight: \(firstWeight?.description)")
                
                
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Fetch Body Fat Measurements
    func fetchBodyFatMeasurements() {
        let bodyFatType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
        let query = HKSampleQuery(sampleType: bodyFatType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, results, error in
            guard let samples = results as? [HKQuantitySample] else {
                if let error = error {
                    print("[HealthKitHelper] Error fetching Body Fat: \(error.localizedDescription)")
                }
                return
            }

            DispatchQueue.main.async {
                for sample in samples {
                    do {
                        let measurement = try BodyFatMeasurement(timestamp: sample.startDate, value: sample.quantity.doubleValue(for: .percent()) * 100)
                        try self.user.bodyFatMeasurements.addOrUpdateMeasurement(measurement)
                    } catch {
                        print("[HealthKitHelper] Error saving Body Fat Measurement: \(error.localizedDescription)")
                    }
                }
                print("[HealthKitHelper] Fetched Body Fat Measurements")
                print("[HealthKitHelper] Most Recent Body Fat Measurement: \(self.user.bodyFatMeasurements.getMostRecentMeasurement()?.description)")
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Fetch Activity Data (Steps, Active Calories, Distance)
      func fetchActivityMeasurements() {
          let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
          let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
          let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

          let queryGroup = DispatchGroup()

          var stepsData: [Date: Double] = [:]
          var activeEnergyData: [Date: Double] = [:]
          var distanceData: [Date: Double] = [:]

          // Fetch Step Count
          queryGroup.enter()
          fetchActivityData(for: stepCountType) { results in
              stepsData = results
              queryGroup.leave()
          }

          // Fetch Active Energy Burned
          queryGroup.enter()
          fetchActivityData(for: activeEnergyType) { results in
              activeEnergyData = results
              queryGroup.leave()
          }

          // Fetch Distance Walked/Run
          queryGroup.enter()
          fetchActivityData(for: distanceType) { results in
              distanceData = results
              queryGroup.leave()
          }

          // When all queries are complete, update the user's activity measurements
          queryGroup.notify(queue: .main) {
              DispatchQueue.main.async {
                  for date in Set(stepsData.keys).union(activeEnergyData.keys).union(distanceData.keys) {
                      let steps = stepsData[date] ?? 0
                      let activeCalories = activeEnergyData[date] ?? 0
                      let distance = distanceData[date] ?? 0

                      do {
                          let activityMeasurement = try self.user.activityMeasurements.getMeasurement(for: date) ??
                              ActivityMeasurement(timestamp: date, steps: 0, distanceWalked: 0, activeCalories: 0)

                          activityMeasurement.steps = Int(steps)
                          activityMeasurement.distanceWalked = distance
                          activityMeasurement.activeCalories = activeCalories

                          try self.user.activityMeasurements.addOrUpdateMeasurement(activityMeasurement)
                      } catch {
                          print("[HealthKitHelper] Error saving ActivityMeasurement for \(date): \(error.localizedDescription)")
                      }
                  }
                  print("[HealthKitHelper] Successfully fetched and stored Activity Measurements.")
                  print("[HealthKitHelper] Most Recent Activity Measurement: \(self.user.activityMeasurements.getMostRecentMeasurement()?.description ?? "No most recent weight measurement")")
              }
          }
      }

      // MARK: - Helper Method to Fetch Activity Data
      private func fetchActivityData(for quantityType: HKQuantityType, completion: @escaping ([Date: Double]) -> Void) {
          let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit,
                                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, results, error in
              guard let samples = results as? [HKQuantitySample] else {
                  if let error = error {
                      print("[HealthKitHelper] Error fetching \(quantityType.identifier): \(error.localizedDescription)")
                  }
                  completion([:])
                  return
              }

              var data: [Date: Double] = [:]
              for sample in samples {
                  let value = sample.quantity.doubleValue(for: self.unit(for: quantityType))
                  let date = sample.startDate.onlyDate()
                  data[date] = (data[date] ?? 0) + value
              }
              completion(data)
          }
          healthStore.execute(query)
      }

      // MARK: - Helper to Get Unit for Each Quantity Type
      private func unit(for quantityType: HKQuantityType) -> HKUnit {
          switch quantityType {
          case HKQuantityType.quantityType(forIdentifier: .stepCount):
              return HKUnit.count()
          case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
              return HKUnit.kilocalorie()
          case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
              return HKUnit.meter()
          default:
              return HKUnit.count()
          }
      }

    // MARK: - Fetch Nutrition Data
    func fetchNutritionData() {
        guard let foodType = HKObjectType.correlationType(forIdentifier: .food) else {
                   print("[HealthKitHelper] Warning: HKCorrelationType.food is unavailable.")
                   return
               }
        let query = HKSampleQuery(sampleType: foodType, predicate: nil, limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, results, error in
            guard let correlations = results as? [HKCorrelation] else {
                if let error = error {
                    print("[HealthKitHelper] Error fetching Nutrition Data: \(error.localizedDescription)")
                    if (error as NSError).code == HKError.errorAuthorizationDenied.rawValue {
                                            print("[HealthKitHelper] Warning: Access to food/nutrition data is denied by the user.")
                        }
                }
                return
            }

            DispatchQueue.main.async {
                for correlation in correlations {
                    let entry = self.parseFoodCorrelation(correlation)

                    do {
                        let date = entry.timestamp.onlyDate()
                        let dailyMeasurement = try self.user.nutritionMeasurements.getMeasurement(for: date) ??
                            NutritionMeasurement(timestamp: date)

                        dailyMeasurement.addOrUpdateEntry(entry)
                        try self.user.nutritionMeasurements.addOrUpdateMeasurement(dailyMeasurement)
                    } catch {
                        print("[HealthKitHelper] Error saving Nutrition Entry: \(error.localizedDescription)")
                    }
                }
                print("[HealthKitHelper] Successfully fetched and stored Nutrition Data.")
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Parse Food Correlation into NutritionEntryMeasurement
    private func parseFoodCorrelation(_ correlation: HKCorrelation) -> NutritionEntryMeasurement {
        let timestamp = correlation.startDate
        var entry = NutritionEntryMeasurement(timestamp: timestamp, kilocalories: 0.0)

        for sample in correlation.objects {
            guard let quantitySample = sample as? HKQuantitySample else { continue }

            switch quantitySample.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed):
                entry.kilocalories = quantitySample.quantity.doubleValue(for: .kilocalorie())

            case HKQuantityType.quantityType(forIdentifier: .dietaryProtein):
                entry.protein = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates):
                entry.carbohydrates = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal):
                entry.fats = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryFiber):
                entry.dietaryFiber = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietarySugar):
                entry.sugar = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietarySodium):
                entry.sodium = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryFatSaturated):
                entry.saturatedFat = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryFatMonounsaturated):
                entry.transFat = quantitySample.quantity.doubleValue(for: .gram())
                
            case HKQuantityType.quantityType(forIdentifier: .dietaryFatPolyunsaturated):
                entry.transFat = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryCholesterol):
                entry.cholesterol = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryPotassium):
                entry.potassium = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryCalcium):
                entry.calcium = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryIron):
                entry.iron = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryVitaminC):
                entry.vitaminC = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryVitaminD):
                entry.vitaminD = quantitySample.quantity.doubleValue(for: .gram())

            case HKQuantityType.quantityType(forIdentifier: .dietaryVitaminB12):
                entry.vitaminB12 = quantitySample.quantity.doubleValue(for: .gram())

            default:
                print("[HealthKitHelper] Warning: Unhandled Nutrition Type: \(quantitySample.quantityType.identifier)")
            }
        }

        return entry
    }
    
    private func validateAndStoreMeasurement<T: Measurement>(_ measurement: T, in collection: inout MeasurementCollection<T>) {
        do {
            try measurement.validate()
            try collection.addOrUpdateMeasurement(measurement)
        } catch {
            print("[HealthKitHelper] Error validating/storing \(T.self): \(error.localizedDescription)")
        }
    }
    
    func refreshHealthKitData() {
        print("[HealthKitHelper] Refreshing all HealthKit data...")
        
        requestHealthKitAuthorization { success in
            guard success else {
                print("[HealthKitHelper] HealthKit authorization denied.")
                return
            }

            DispatchQueue.global(qos: .background).async {
                self.fetchPersonData()
                self.fetchWeightMeasurements()
                self.fetchBodyFatMeasurements()
                self.fetchActivityMeasurements()
                //self.fetchNutritionData()
            }
        }
    }
    
    private func needsUpdate(for type: HKQuantityTypeIdentifier, lastUpdate: Date?) -> Bool {
        guard let lastUpdate = lastUpdate else { return true }
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        return lastUpdate < oneDayAgo
    }
    
    func getLastUpdateDates() -> [String: Date?] {
        return [
            "Weight": user.weightMeasurements.getMostRecentMeasurement()?.timestamp,
            "Body Fat": user.bodyFatMeasurements.getMostRecentMeasurement()?.timestamp,
            "Activity": user.activityMeasurements.getMostRecentMeasurement()?.timestamp,
            "Nutrition": user.nutritionMeasurements.getMostRecentMeasurement()?.timestamp
        ]
    }
    
    private func batchStoreMeasurements<T: Measurement>(_ measurements: [T], in collection: inout MeasurementCollection<T>) {
        for measurement in measurements {
            validateAndStoreMeasurement(measurement, in: &collection)
        }
    }
    
    func deleteOldMeasurements(before date: Date, in collection: inout MeasurementCollection<Measurement>) {
        let measurements = collection.getAllMeasurements()
        for measurement in measurements {
            if measurement.timestamp < date {
                collection.deleteMeasurement(for: measurement.timestamp)
            }
        }
    }
    
    func clearAllHealthKitData() {
        user.weightMeasurements = MeasurementCollection()
        user.bodyFatMeasurements = MeasurementCollection()
        user.activityMeasurements = MeasurementCollection()
        user.nutritionMeasurements = MeasurementCollection()
        print("[HealthKitHelper] Cleared all stored HealthKit data.")
    }
}
// MARK: - Convert HKBiologicalSex to String
extension HKBiologicalSex {
    var stringValue: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        default: return "Unknown"
        }
    }
}
