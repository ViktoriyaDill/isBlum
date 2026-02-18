//
//  AddressResultRow.swift
//  isBlum
//
//  Created by Пользователь on 13/02/2026.
//

import Foundation
import SwiftUI

struct AddressResultRow: View {
    let address: AddressModel
    let isSelected: Bool 
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(.geolocationPin)
                        .font(.system(size: 14, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.street)
                        .font(.onest(.bold, size: 15))
                        .foregroundColor(.black)
                    
                    Text(address.city)
                        .font(.onest(.regular, size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(isSelected ? Color(hex: "E6F7E9") : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "B2E3B9") : Color.clear, lineWidth: 1) 
            )
            
            if !isSelected {
                Divider()
                    .padding(.leading, 76)
            }
        }
        .padding(.horizontal, 8)
    }
}

