//
//  ProfileCard.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct ProfileCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white)
        .cornerRadius(32)
    }
}
