//
//  TrendMeasurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/27/24.
//
import Foundation
protocol TrendMeasurementProtocol : Measurement {
    var hasRecordedMeasurement: Bool { get set } // True if there is a corresponding recorded measurement
    var calculationMethod: String { get set } // Description of the calculation method
    var calculatedAt: Date { get set } // Timestamp of when the trend value was calculated
    
}
