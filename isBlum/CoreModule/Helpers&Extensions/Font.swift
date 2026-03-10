//
//  Font.swift
//  isBlum
//
//  Created by Пользователь on 09/02/2026.
//

import Foundation
import SwiftUI

extension Font {
    static func onest(_ weight: OnestWeight, size: CGFloat) -> Font {
        return .custom(weight.rawValue, size: size)
    }
    
    enum OnestWeight: String {
        case thin = "Onest-Thin"
        case extraLight = "Onest-ExtraLight"
        case light = "Onest-Light"
        case regular = "Onest-Regular"
        case medium = "Onest-Medium"
        case semiBold = "Onest-SemiBold"
        case bold = "Onest-Bold"
        case extraBold = "Onest-ExtraBold"
        case black = "Onest-Black"
    }
}
