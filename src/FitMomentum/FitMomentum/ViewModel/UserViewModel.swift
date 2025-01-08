//
//  UserViewModel.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/8/25.
//

import Foundation
import HealthKit

class UserViewModel: ObservableObject {
    // Published properties for the View to observe
    @Published var user: User?
    @Published var dateOfBirth: Date?
    @Published var height: Double?
    @Published var weight: Double?

    private var healthStore = HKHealthStore()

    init() {
        // Initialize an empty User object
        self.user = User(person: Person(), preferences: UserPreferences())
    }

    // MARK: - HealthKit Access
    
    /// Request HealthKit permissions
    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            if success {
                self?.fetchHealthKitData()
            } else if let error = error {
                print("HealthKit Authorization Error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Fetch Data from HealthKit

    /// Fetch HealthKit data and populate the model
    private func fetchHealthKitData() {
        do {
            let dobComponents = try healthStore.dateOfBirthComponents()
            if let dob = Calendar.current.date(from: dobComponents) {
                user?.person.dateOfBirth = dob
            }

            let biologicalSex = try healthStore.biologicalSex().biologicalSex
            switch biologicalSex {
            case .male:
                user?.person.sex = "male"
            case .female:
                user?.person.sex = "female"
            case .other:
                user?.person.sex = "other"
            default:
                user?.person.sex = "unknown"
            }

            fetchMostRecentHeight()
            fetchMostRecentWeight()
        } catch {
            print("Error fetching HealthKit data: \(error.localizedDescription)")
        }
    }

    /// Fetch most recent height
    private func fetchMostRecentHeight() {
        guard let heightType = HKSampleType.quantityType(forIdentifier: .height) else { return }

        let query = HKSampleQuery(
            sampleType: heightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, results, error in
            if let error = error {
                print("Error fetching height: \(error.localizedDescription)")
                return
            }

            if let heightSample = results?.first as? HKQuantitySample {
                let heightInMeters = heightSample.quantity.doubleValue(for: HKUnit.meter())
                self?.height = heightInMeters
                self?.user?.person.height = heightInMeters
            }
        }

        healthStore.execute(query)
    }

    /// Fetch most recent weight
    private func fetchMostRecentWeight() {
        guard let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) else { return }

        let query = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, results, error in
            if let error = error {
                print("Error fetching weight: \(error.localizedDescription)")
                return
            }

            if let weightSample = results?.first as? HKQuantitySample {
                let weightInKilograms = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let dateOfRecentWeight = weightSample.startDate
                self?.weight = weightInKilograms
                do {
                    try self?.user?.weightMeasurements.addOrUpdateMeasurement(
                        WeightMeasurement(timestamp: dateOfRecentWeight, value: weightInKilograms)
                    )
                } catch {
                    print("Error saving weight: \(error.localizedDescription)")
                    return
                }
                
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Save User Data
    func saveUser(dateOfBirth: Date?, height: Double?, weight: Double?, sex: String) {
        if let dateOfBirth = dateOfBirth {
            user?.person.dateOfBirth = dateOfBirth
        }
        if let height = height {
            user?.person.height = height
        }
        user?.person.sex = sex

        do {
            if let weight = weight {
                try user?.weightMeasurements.addOrUpdateMeasurement(
                    WeightMeasurement(timestamp: Date(), value: weight)
                )
            }
        } catch {
            print("Error saving user data \(error.localizedDescription)")
        }
        
    }
}

// MARK: - Extensions for Helper Functions
extension HKBiologicalSex {
    var stringRepresentation: String {
        switch self {
        case .male: return "male"
        case .female: return "female"
        case .other: return "other"
        default: return "unknown"
        }
    }
}
