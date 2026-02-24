//
//  NotificationButton.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct NotificationButton: View {
    let count: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(.notification)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
            
            if count > 0 {
                Text("\(count)")
                    .font(.onest(.regular, size: 12))
                    .foregroundColor(.black)
                    .padding(4)
                    .background(Color(hex: "9AF19A"))
                    .clipShape(Circle())
                    .offset(x: 2, y: -2)
            }
        }
    }
}
