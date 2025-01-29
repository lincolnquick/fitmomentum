//
//  ProfilePage.swift
//

import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject var userViewModel: UserViewModel

    // UI states
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 7

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Profile Information
                Section(header: Text("Profile Information")) {
                    VStack(alignment: .leading, spacing: 5) {
                        let dob = userViewModel.user.person.dateOfBirth
                        let age = userViewModel.user.person.getAge()
                        Text("Date of Birth: \(dob.formatted(.dateTime.month().day().year())) (Age: \(age))")
                        
                    }

                    Text("Gender: \(userViewModel.user.person.sex.capitalized)")

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Height")
                            .font(.headline)

                        if userViewModel.userPrefs.unitPreferences.heightUnit == .ftIn {
                            HStack {
                                Picker("Feet", selection: $heightFeet)
                                {
                                    ForEach(4...7, id: \.self) { feet in
                                        Text("\(feet) ft").tag(feet)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                

                                Picker("Inches", selection: $heightInches)
                                {
                                    ForEach(0...11, id: \.self) { inches in
                                        Text("\(inches) in").tag(inches)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                
                            }
                            .onChange(of: heightFeet) { oldValue, newValue in
                                userViewModel.updateHeightFromFeetAndInches(feet: newValue, inches: heightInches)
                            }
                            .onChange(of: heightInches) { oldValue, newValue in
                                userViewModel.updateHeightFromFeetAndInches(feet: heightFeet, inches: newValue)
                            }
                        } else {
                            HStack {
                                TextField("Height", text: Binding(
                                    get: { String(format: "%.1f", userViewModel.user.person.height) },
                                    set: { newValue in
                                        userViewModel.user.person.height = Double(newValue) ?? userViewModel.user.person.height
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                                Text("cm").foregroundColor(.gray)
                            }
                        }
                    }
                }

                // MARK: - Latest Measurements
                Section(header: Text("Latest Measurements")) {
                    Text("Weight: \(userViewModel.formattedWeight())")
                    Text("Body Fat: \(userViewModel.formattedBodyFat())")
                    
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                userViewModel.refreshHealthKitData()
                heightFeet = userViewModel.getHeightFeet()
                heightInches = userViewModel.getHeightInches()
            }
        }
    }
}
