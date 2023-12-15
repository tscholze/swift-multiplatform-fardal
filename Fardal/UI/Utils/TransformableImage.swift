//
//  TransformableImage.swift
//  Fardal
//
//  Created by Tobias Scholze on 15.12.23.
//

import Foundation
import SwiftUI

struct TransformableImage: Transferable {
    let image: Image
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                fatalError("Data to image transfer failed.")
            }
            
            return TransformableImage(image: Image(uiImage: uiImage))
        }
    }
}
