//
//  MapSelectionButton.swift
//  isBlum
//
//  Created by Пользователь on 13/02/2026.
//

import SwiftUI

struct MapSelectionButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "map")
                    .font(.system(size: 18))
                Text("address_show_on_map")
                    .font(.onest(.medium, size: 16))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
}
