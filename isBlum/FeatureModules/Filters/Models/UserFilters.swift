//
//  OccasionModel.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import Foundation
import SwiftUI

struct OccasionModel: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let iconName: String
}

struct UserFilters: Codable {
    var occasions: [String] = []
    var bouquetTypes: [String] = []
    var flowers: [String] = []
    var priceMin: Int = 0
    var priceMax: Int = 15000
}
