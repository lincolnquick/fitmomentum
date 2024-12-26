//
//  Measurement.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/25/24.
//
import Foundation
class Measurement : MeasurementProtocol {
    var timestamp: Date
    
    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
    }
    
    func validate() throws {
        // Default implementation is no validation
    }
}
