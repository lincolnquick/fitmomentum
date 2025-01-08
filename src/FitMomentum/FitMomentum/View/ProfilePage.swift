//
//  ProfilePage.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/8/25.
//

import SwiftUI

struct ProfilePage: View {
    @State private var dateOfBirth: Date = Date()
    @State private var height: Double = 0.0
    @State private var weight: Double = 0.0
    @State private var sex: String = "other" // Default to "other"
    @State private var showDatePicker = false
    @State private var showWeightInput = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    // Date of Birth
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Date of Birth")
                            .font(.headline)
                        if showDatePicker {
                            DatePicker(
                                "",
                                selection: $dateOfBirth,
                                displayedComponents: .date
                            )
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            Button("Save Date") {
                                if validateAge(dateOfBirth: dateOfBirth) {
                                    showDatePicker = false
                                } else {
                                    alertMessage = "You must be at least 18 years old."
                                    showAlert = true
                                }
                            }
                            .foregroundColor(.blue)
                        } else {
                            Text(dateOfBirth, style: .date)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    showDatePicker = true
                                    dismissKeyboard()
                                }
                        }
                    }
                    .padding(.vertical)

                    // Sex
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Gender")
                            .font(.headline)
                        Picker("", selection: $sex) {
                            Text("Male").tag("male")
                            Text("Female").tag("female")
                            Text("Nonbinary").tag("other")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.vertical)

                    // Height
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Height (\(UserPreferences.shared.unitPreferences.heightUnit.rawValue))")
                            .font(.headline)
                        TextField("Enter Height", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isFieldFocused)
                    }
                    .padding(.vertical)

                    // Weight
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Current Weight (\(UserPreferences.shared.unitPreferences.weightUnit.rawValue))")
                            .font(.headline)
                        HStack {
                            if weight > 0.0 {
                                Text("\(weight, specifier: "%.2f")")
                                    .foregroundColor(.primary)
                            } else {
                                Text("-")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                showWeightInput = true
                                dismissKeyboard()
                            }) {
                                Text("Add Weight")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarItems(
                trailing: Button("Save") {
                    saveProfile()
                }
                .foregroundColor(.blue)
            )
            .onTapGesture {
                dismissKeyboard()
                showDatePicker = false
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showWeightInput) {
                WeightInputView(weight: $weight, unit: UserPreferences.shared.unitPreferences.weightUnit.rawValue)
            }
        }
    }

    // Save Profile Action
    private func saveProfile() {
        guard validateAge(dateOfBirth: dateOfBirth) else {
            alertMessage = "You must be at least 18 years old."
            showAlert = true
            return
        }

        // Add saving logic here (e.g., save to UserPreferences or User object)
        print("Profile saved: \(dateOfBirth), \(height), \(weight), \(sex)")
    }

    // Validate Age
    private func validateAge(dateOfBirth: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year ?? 0
        return age >= 18
    }

    // Dismiss Keyboard
    private func dismissKeyboard() {
        isFieldFocused = false
    }
}

struct WeightInputView: View {
    @Binding var weight: Double
    let unit: String
    @State private var weightInput: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Weight (\(unit))")) {
                    TextField("Weight", text: $weightInput)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if let weightValue = Double(weightInput) {
                        weight = weightValue
                    }
                    dismiss()
                }
            )
        }
    }
}
