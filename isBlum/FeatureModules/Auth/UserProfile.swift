//
//  UserProfile.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import Foundation

struct UserProfile: Codable {
    let id: UUID
    var name: String?
    var phone: String?
    var email: String?
    var avatarUrl: String?
    var isPhoneVerified: Bool
    var isEmailVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, phone, email
        case avatarUrl = "avatar_url"
        case isPhoneVerified = "is_phone_verified"
        case isEmailVerified = "is_email_verified"
    }
}
