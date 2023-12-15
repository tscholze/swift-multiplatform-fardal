//
//  Image.swift
//  Fardal
//
//  Created by Tobias Scholze on 15.12.23.
//

import Foundation
import SwiftData
import UIKit

@Model
final class ImageData {
    @Attribute(.unique)
    let id = UUID()
    
    let data: Data
    
    let createdAt = Date.now
    
    var uiImage: UIImage {
        guard let image = UIImage(data: data) else {
            fatalError("Corrupt image")
        }
        
        return image
    }
    
    init(data: Data) {
        self.data = data
    }
    
    // MARK: - Equatable -

    public static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        return lhs.id == rhs.id
    }
}
