//
//  SettingsSection.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct SettingsGroupView: View {
    let isLoggedIn: Bool
    
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.openURL) private var openURL
    
    // MARK: - State & Storage
    // AppStorage automatically updates the UI when the value changes
    @AppStorage("app_language") private var selectedLanguage: String = "uk"
    @AppStorage("app_currency") private var selectedCurrency: String = "UAH"
    
    // State to control which modal is shown
    @State private var activeModal: SelectionType?
    
    // Helper to get readable title for subtitle
    private var languageDisplay: String {
        switch selectedLanguage {
        case "uk": return "Українська"
        case "en": return "English"
        case "ru": return "Русский"
        default: return "Українська"
        }
    }
    
    var body: some View {
        ProfileCard(content: {
            VStack(alignment: .leading, spacing: 16) {
                Text("Налаштування")
                    .font(.onest(.bold, size: 16))
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                
                VStack(spacing: 16) {
                    // MARK: - Language Row
                    ProfileMenuRow(
                        icon: .globe,
                        title: "Мова",
                        subtitle: languageDisplay
                    ) {
                        activeModal = .language
                    }
                    
                    Divider()
                    
                    // MARK: - Currency Row
                    ProfileMenuRow(
                        icon: .banknote,
                        title: "Валюта",
                        subtitle: selectedCurrency
                    ) {
                        activeModal = .currency
                    }
                    
                    Divider()
                    
                    if isLoggedIn {
                        ProfileMenuRow(icon: .bell, title: "Налаштування сповіщень") {
                            coordinator.showNotificationSettings()
                        }
                        Divider()
                    }
                    
                    ProfileMenuRow(icon: .help, title: "Підтримка") {
                        coordinator.showSupport()
                    }
                    
                    Divider()
                    
                    ProfileMenuRow(icon: .shop, title: "Розмістити свій магазин"){
                        if let url = URL(string: "itms-apps://apps.apple.com/app/id544007664") {
                            openURL(url)
                        }
                    }
                    
                    Divider()
                    
                    ProfileMenuRow(icon: .info, title: "Про додаток") {
                        coordinator.showAboutApp()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        })
        // MARK: - Modal Presentation
        .sheet(item: $activeModal) { type in
            SelectionModalView(type: type)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// Make SelectionType identifiable for the .sheet(item:) call
extension SelectionType: Identifiable {
    var id: Self { self }
}

struct ProfileMenuRow: View {
    let icon: UIImage
    let title: LocalizedStringResource
    var subtitle: String? = nil
    var showArrow: Bool = true
    
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(uiImage: icon)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.onest(.medium, size: 16))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.onest(.regular, size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .frame(height: 40)
        .onTapGesture {
            action()
        }
    }
    
}
