//
//  TermsOfServiceView.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI

struct TermsOfServiceView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            CustomNavigationBar(
                title: LocalizedStringResource(stringLiteral: "Користувацька угода"),
                showBackButton: true,
                backAction: { coordinator.popProfile() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("tos_main_title")
                            .font(.onest(.bold, size: 24))
                        
                        Text("tos_last_updated")
                            .font(.onest(.regular, size: 16))
                            .foregroundColor(Color(hex: "#535852"))
                    }
                    .padding(.bottom, 10)
                    
                    // Main Text Content
                    Group {
                        Text("tos_intro_1")
                        
                        sectionHeader("tos_section_1_title")
                        Text("tos_section_1_body")
                        
                        sectionHeader("tos_section_2_title")
                        Text("tos_section_2_body")
                        
                        sectionHeader("tos_section_3_title")
                        Text("tos_section_3_body")
                    }
                    
                    Group {
                        sectionHeader("tos_section_4_title")
                        Text("tos_section_4_body")
                        
                        sectionHeader("tos_section_5_title")
                        Text("tos_section_5_body")
                        
                        sectionHeader("tos_section_6_title")
                        Text("tos_section_6_body")
                    }
                    
                    Group {
                        sectionHeader("tos_section_7_title")
                        Text("tos_section_7_body")
                        
                        sectionHeader("tos_section_8_title")
                        Text("tos_section_8_body")
                    }
                }
                .font(.onest(.regular, size: 15))
                .lineSpacing(4)
                .padding(20)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
    
    // Helper to keep headers consistent
    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.onest(.bold, size: 17))
            .padding(.top, 10)
    }
}
