//
//  ChartData.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 1/29/25.
//
import Foundation

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let secondaryValue: Double? // Used for Energy Balance (TDEE)
}
