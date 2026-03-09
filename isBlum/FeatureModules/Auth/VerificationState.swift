//
//  AuthStateModel.swift
//  isBlum
//
//  Created by Пользователь on 09/03/2026.
//

import Foundation

enum VerificationState {
    case idle
    case loading    // Checking the code...
    case error      // Incorrect code
    case success    // Code is correct
}
