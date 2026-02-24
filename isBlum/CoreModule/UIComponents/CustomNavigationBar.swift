//
//  CustomNavigationBar.swift
//  isBlum
//
//  Created by Пользователь on 13/02/2026.
//

import Foundation
import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    var showBackButton: Bool = true
    var backAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("locationTopBackground")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .ignoresSafeArea(edges: .top)
            
            HStack {
                if showBackButton {
                    Button(action: { backAction?() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                } else {
                    // Placeholder для збереження симетрії заголовка
                    Color.clear.frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text(title)
                    .font(.onest(.bold, size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .frame(height: 64)
    }
}
