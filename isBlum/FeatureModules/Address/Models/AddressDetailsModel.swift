//
//  AddressDetails.swift
//  isBlum
//
//  Created by Пользователь on 18/02/2026.
//

import Foundation

struct AddressDetails: Codable {
    let streetAddress: String
    let apartment: String
    let entrance: String
    let floor: String
    let intercom: String
    
    // Calculated full string for UI
    var fullDisplayAddress: String {
        var parts = [streetAddress]
        if !apartment.isEmpty { parts.append("кв. \(apartment)") }
        if !floor.isEmpty { parts.append("пов. \(floor)") }
        return parts.joined(separator: ", ")
    }
}
