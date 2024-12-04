//
//  Item.swift
//  FitMomemtum
//
//  Created by Lincoln Quick on 12/3/24.
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
