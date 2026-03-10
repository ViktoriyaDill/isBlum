//
//  View+HideKeyboard.swift
//  isBlum
//
//  Created by Пользователь on 10/03/2026.
//

import Foundation
import SwiftUI

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
