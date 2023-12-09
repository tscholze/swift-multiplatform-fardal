//
//  Item.swift
//  Fardal
//
//  Created by Tobias Scholze on 09.12.23.
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
