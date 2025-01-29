//
//  PreferencesPage.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/8/25.
//

import SwiftUI

struct PreferencesPage: View {
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Appearance
                Section(header: Text("Appearance")) {
                    Picker("Appearance Mode", selection: $userViewModel.userPrefs.appearanceMode) {
                        Text("Light").tag(UserPreferences.AppearanceMode.light)
                        Text("Dark").tag(UserPreferences.AppearanceMode.dark)
                        Text("System").tag(UserPreferences.AppearanceMode.system)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // MARK: - Units
                Section(header: Text("Units")) {
                    Picker("Weight Unit", selection: $userViewModel.userPrefs.unitPreferences.weightUnit) {
                        Text("Kilograms (kg)").tag(UserPreferences.WeightUnit.kg)
                        Text("Pounds (lbs)").tag(UserPreferences.WeightUnit.lbs)
                        Text("Stones").tag(UserPreferences.WeightUnit.stones)
                    }

                    Picker("Height Unit", selection: $userViewModel.userPrefs.unitPreferences.heightUnit) {
                        Text("Centimeters (cm)").tag(UserPreferences.HeightUnit.cm)
                        Text("Feet & Inches").tag(UserPreferences.HeightUnit.ftIn)
                    }

                    Picker("Distance Unit", selection: $userViewModel.userPrefs.unitPreferences.distanceUnit) {
                        Text("Kilometers (km)").tag(UserPreferences.DistanceUnit.km)
                        Text("Miles (mi)").tag(UserPreferences.DistanceUnit.mi)
                    }

                    Picker("Energy Unit", selection: $userViewModel.userPrefs.unitPreferences.energyUnit) {
                        Text("Kilocalories (kcal)").tag(UserPreferences.EnergyUnit.kcal)
                        Text("Megajoules (mj)").tag(UserPreferences.EnergyUnit.mj)
                    }
                }

                // MARK: - Health & Activity Goals
                Section(header: Text("Goals & Reminders")) {
                    Stepper(
                        value: $userViewModel.userPrefs.dailyStepGoal,
                        in: 0...30000,
                        step: 1000
                    ) {
                        Text("Daily Step Goal: \(userViewModel.userPrefs.dailyStepGoal)")
                    }

                    Toggle("Weigh-In Reminder", isOn: $userViewModel.userPrefs.weighInReminderEnabled)
                    if userViewModel.userPrefs.weighInReminderEnabled {
                        DatePicker("Reminder Time", selection: Binding(
                            get: { userViewModel.userPrefs.weighInReminderTime ?? Date() },
                            set: { userViewModel.userPrefs.weighInReminderTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                    }

                    Toggle("Use Recommended Minimum Calorie Target", isOn: $userViewModel.userPrefs.useRecommendedMinimumCalorieTarget)
                        .help("This will ensure that any recommended daily calorie target is no less than 1200 kcal.")
                }

                // MARK: - HealthKit Authorization
                Section(header: Text("HealthKit Authorization")) {
                    if userViewModel.isHealthKitAuthorized {
                        Text("HealthKit: Authorized").foregroundColor(.green)
                    } else {
                        Text("HealthKit: Not Authorized").foregroundColor(.red)
                    }
                }

                // MARK: - Health Data
                Section(header: Text("Health Data")) {
                    Button("Refresh Health Data") {
                        userViewModel.refreshHealthKitData()
                    }
                    .foregroundColor(.blue)

                    if !userViewModel.isHealthKitAuthorized {
                        Text("Warning: Some data (e.g., Nutrition) may not be available.")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Preferences")
        }
    }
}
