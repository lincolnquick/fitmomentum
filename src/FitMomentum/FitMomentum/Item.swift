//
//  Item.swift
//  FitMomentum
//
//  Created by Lincoln Quick on 12/4/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
