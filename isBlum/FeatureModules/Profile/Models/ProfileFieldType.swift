//
//  ProfileFieldType.swift
//  isBlum
//
//  Created by Пользователь on 09/03/2026.
//

import Foundation
import SwiftUI

enum ProfileFieldType {
    case name, phone, email
    
    var title: LocalizedStringResource {
        switch self {
        case .name: return "Ім'я"
        case .phone: return "Номер телефону"
        case .email: return "Електронна пошта"
        }
    }
    
    var iconName: String {
        switch self {
        case .name: return "person"
        case .phone: return "phone"
        case .email: return "envelope"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .name: return .default
        case .phone: return .phonePad
        case .email: return .emailAddress
        }
    }
}
