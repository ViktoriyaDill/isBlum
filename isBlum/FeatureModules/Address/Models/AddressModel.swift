//
//  AddressModel.swift
//  isBlum
//
//  Created by Пользователь on 18/02/2026.
//

import Foundation

struct AddressModel: Identifiable, Equatable {
    let id = UUID()
    let street: String
    let city: String
    
    // Computed property to fix the error
    var title: String {
        if city.isEmpty {
            return street
        } else {
            return "\(street), \(city)"
        }
    }
    
    static func == (lhs: AddressModel, rhs: AddressModel) -> Bool {
        lhs.id == rhs.id
    }
}
