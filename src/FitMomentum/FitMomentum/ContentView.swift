//
//  ContentView.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/4/24.
//

import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    let healthStore = HKHealthStore()
    
    // Define the data types to read
    let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    // Define the data types to write
    let writeTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!
    ]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            VStack {
                Text("Select an item")
                
                // Add buttons to trigger HealthKit actions
                Button("Request HealthKit Authorization") {
                    requestHealthKitAuthorization()
                }
                .padding()

                Button("Fetch Weight Data") {
                    fetchWeightSamples()
                }
                .padding()
                
                Button("Save Weight Sample") {
                    saveWeightSample(weightInKg: 70.0, date: Date())
                }
                .padding()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    // MARK: - HealthKit Functions

    /// Request authorization to access HealthKit data
    private func requestHealthKitAuthorization() {
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
            if success {
                print("HealthKit authorization granted.")
            } else {
                print("HealthKit authorization denied. Error: \(String(describing: error))")
            }
        }
    }

    /// Fetch recent weight samples from HealthKit
    private func fetchWeightSamples() {
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 10, sortDescriptors: [sortDescriptor]) { query, results, error in
            if let error = error {
                print("Error fetching weight samples: \(error.localizedDescription)")
                return
            }
            
            if let results = results as? [HKQuantitySample] {
                for sample in results {
                    let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    let date = sample.startDate
                    print("Weight: \(weightInKg) kg, Date: \(date)")
                }
            }
        }
        healthStore.execute(query)
    }

    /// Save a weight sample to HealthKit
    private func saveWeightSample(weightInKg: Double, date: Date) {
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let weightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weightInKg)
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: date, end: date)
        
        healthStore.save(weightSample) { (success, error) in
            if success {
                print("Weight sample saved successfully.")
            } else {
                print("Error saving weight sample: \(String(describing: error))")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
