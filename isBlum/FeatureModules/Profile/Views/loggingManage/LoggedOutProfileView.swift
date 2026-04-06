//
//  LoggedOutProfileView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct LoggedOutProfileView: View {
    
    let authAction: () -> Void
    
    var body: some View {
        ProfileCard {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("profile_login_description")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        authAction()
                    }) {
                        Text("profile_login_button")
                            .font(.onest(.medium, size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "9AF19A"))
                            .cornerRadius(27)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
        }
    }
}
