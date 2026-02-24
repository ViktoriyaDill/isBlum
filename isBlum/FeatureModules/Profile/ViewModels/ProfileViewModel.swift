//
//  ProfileViewModel.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import Foundation


class ProfileViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user: ProfileModel? = nil
}
