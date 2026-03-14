//
//  SelectionType.swift
//  isBlum
//
//  Created by Пользователь on 10/03/2026.
//

import Foundation


enum SelectionType {
    case language
    case currency
    
    var title: String {
        switch self {
        case .language: return "Мова додатка"
        case .currency: return "Валюта"
        }
    }
}

struct SelectionOption: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String? 
}
