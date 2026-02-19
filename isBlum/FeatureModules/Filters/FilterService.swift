//
//  FilterService.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import Foundation

final class FilterService {
    static let shared = FilterService()
    private init() {}
    
    private let key = "userFilters"
    
    // Завантажити збережені фільтри
    func load() -> UserFilters {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let filters = try? JSONDecoder().decode(UserFilters.self, from: data)
        else {
            return UserFilters()
        }
        return filters
    }
    
    // Зберегти фільтри
    func save(_ filters: UserFilters) {
        guard let data = try? JSONEncoder().encode(filters) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // Очистити фільтри
    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
