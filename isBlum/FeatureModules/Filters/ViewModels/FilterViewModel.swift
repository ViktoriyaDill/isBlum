//
//  FilterViewModel.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import Foundation

class FilterViewModel: ObservableObject {
    @Published var selectedOccasions: Set<String> = []
    @Published var selectedBouquetTypes: Set<String> = []
    @Published var selectedFlowers: Set<String> = []
    @Published var priceMin: Int = 0
    @Published var priceMax: Int = 15000
    
    init() {
        load()
    }
    
    // MARK: - Toggle
    func toggleOccasion(_ title: String) {
        toggle(title, in: &selectedOccasions)
    }
    func toggleBouquetType(_ title: String) {
        toggle(title, in: &selectedBouquetTypes)
    }
    func toggleFlower(_ title: String) {
        toggle(title, in: &selectedFlowers)
    }
    
    // MARK: - Check
    func isOccasionSelected(_ title: String) -> Bool { selectedOccasions.contains(title) }
    func isBouquetTypeSelected(_ title: String) -> Bool { selectedBouquetTypes.contains(title) }
    func isFlowerSelected(_ title: String) -> Bool { selectedFlowers.contains(title) }
    
    // MARK: - Persist
    func save() {
        let filters = UserFilters(
            occasions: Array(selectedOccasions),
            bouquetTypes: Array(selectedBouquetTypes),
            flowers: Array(selectedFlowers),
            priceMin: priceMin,
            priceMax: priceMax
        )
        FilterService.shared.save(filters)
    }
    
    private func load() {
        let filters = FilterService.shared.load()
        selectedOccasions = Set(filters.occasions)
        selectedBouquetTypes = Set(filters.bouquetTypes)
        selectedFlowers = Set(filters.flowers)
        priceMin = filters.priceMin
        priceMax = filters.priceMax
    }
    
    private func toggle(_ value: String, in set: inout Set<String>) {
        if set.contains(value) { set.remove(value) } else { set.insert(value) }
    }
}
