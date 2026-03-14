//
//  ReviewHandler.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI
import StoreKit

import StoreKit
import UIKit

struct ReviewHandler {
    
    /// Requests the in-app review popup
    static func requestReview() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else {
                print("ERROR: No active UIWindowScene found")
                return
            }
            
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
