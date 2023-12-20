//
//  UIDevice+System.swift
//  Fardal
//
//  Created by Tobias Scholze on 18.12.23.
//

import UIKit

extension UIDevice {
    /// `true` if it is a simulator (read only)
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)

        return true

        #else

        return false

        #endif
    }
}
