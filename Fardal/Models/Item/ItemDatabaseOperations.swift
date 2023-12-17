//
//  ItemDatabaseOperations.swift
//  Fardal
//
//  Created by Tobias Scholze on 17.12.23.
//

import SwiftUI
import Foundation
import SwiftData

/// Convinient helper to have easy access to
/// database operations in context of an `Item`.
class ItemDatabaseOperations {
    // MARK: - Properties -
    
    /// Shared instance of operations helper.
    static let shared = ItemDatabaseOperations()
    
    // MARK: - Private properties
    
    @Query private var items: [Item]
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Init -
    
    private init() {
        // Only accessable using `shared.`
    }
    
    /// Deletes an `item` from local database for given id
    ///
    /// - Parameter id: ID of the item that shall be deleted.
    func delete(withId id: UUID) {
        guard let itemToDelete = items.first(where: { $0.id ==  id}) else {
            print("Cannot delete item with id `\(id)` because it was not found in database")
            return
        }
        
        modelContext.delete(itemToDelete)
    }
}
