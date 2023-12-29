//
//  FardalConstants.swift
//  Fardal
//
//  Created by Tobias Scholze on 21.12.23.
//

import Foundation

enum FardalConstants {
    enum Collection {
        static let systemUnlinkedItemsCollectionTitle: String = "__unlinkedItems"
    }

    enum Item {
        static let maxNumberOfAttributesPerItem = 5
        static let maxNumberOfPhotosPerItem = 3
        static let maxLengthOfNoteText = 10
    }

    enum Links {
        static let githubUrl = URL(string: "https://github.com/tscholze/swift-multiplatform-fardal")!
        static let contactUrl = URL(string: "http://twitter.com/tobonaut")!
    }
}
