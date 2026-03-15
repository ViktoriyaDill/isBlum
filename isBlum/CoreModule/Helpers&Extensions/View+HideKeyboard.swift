//
//  View+HideKeyboard.swift
//  isBlum
//
//  Created by Пользователь on 10/03/2026.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}


final class KeyboardManager {

    static func dismiss() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
