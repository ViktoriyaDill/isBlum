//
//  LocationService.swift
//  isBlum
//
//  Created by Пользователь on 18/02/2026.
//

import Foundation


class LocationService {
    static let shared = LocationService()
    
    private let addressKey = "userAddress"
    private let fullDetailsKey = "fullAddressDetails"
    
    private init() {}
    
    func saveFullAddress(details: AddressDetails) {
        // Save the main string for quick access
        UserDefaults.standard.set(details.streetAddress, forKey: addressKey)
        
        // Save the whole object as JSON
        if let encoded = try? JSONEncoder().encode(details) {
            UserDefaults.standard.set(encoded, forKey: fullDetailsKey)
        }
    }
    
    func loadFullAddress() -> AddressDetails? {
        guard let data = UserDefaults.standard.data(forKey: fullDetailsKey) else { return nil }
        return try? JSONDecoder().decode(AddressDetails.self, from: data)
    }
}
