//
//  Currency.swift
//  Fardal
//
//  Created by Tobias Scholze on 15.12.23.
//

import Foundation

/// Contains a list of supported currencies.
enum SupportedCurrencies: CaseIterable, Identifiable {
    // MARK: - Cases -
    
    /// Euro, EUR
    case eur
    
    /// US-american Dollar, USD
    case usd
    
    /// Swiss franc
    case CHF
    
    // MARK: - Properties -
    
    /// Identifiable id
    var id: String {
        return code
    }
    
    /// Currency code
    var code: String {
        return switch self {
        case .eur: "EUR"
        case .usd: "USD"
        case .CHF: "CHF"
        }
    }
}
