//
//  CollectionDatabaseOperations.swift
//  Fardal
//
//  Created by Tobias Scholze on 23.12.23.
//

import SwiftData
import Foundation

class CollectionDatabaseOperations {
    // MARK: - Properties -

    /// Shared instance of operations helper.
    static let shared = CollectionDatabaseOperations()

    static var allWithoutSystemCollection = #Predicate<CollectionModel> {
        $0.title != "__unlinkedItems" //
    }
}
