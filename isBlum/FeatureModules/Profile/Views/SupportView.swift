//
//  SupportView.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var messageText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            CustomNavigationBar(
                title: "Підтримка",
                showBackButton: true,
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Text
                    VStack(spacing: 8) {
                        Text("support_header_title")
                            .font(.onest(.bold, size: 22))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("support_header_description")
                            .font(.onest(.regular, size: 15))
                            .foregroundColor(.gray)
                            .lineSpacing(2)
                    }
                    .padding(.top, 10)
                    
                    // Message Input Field
                    ZStack(alignment: .topLeading) {
                        if messageText.isEmpty {
                            Text("support_placeholder")
                                .font(.onest(.regular, size: 16))
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        
                        TextEditor(text: $messageText)
                            .font(.onest(.regular, size: 16))
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .focused($isTextFieldFocused)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer(minLength: 20)
                    
                    // Send Button
                    Button(action: {
                        handleSendMessage()
                    }) {
                        Text("support_send_button")
                            .font(.onest(.medium, size: 16))
                            .foregroundColor(Color(hex: "#070A07"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : Color(hex: "#9AF19A"))
                            .cornerRadius(27)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(20)
            }
            .background(Color.white)
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
        .alert("Підтримка", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .navigationBarHidden(true)
    }
    
    private func handleSendMessage() {
        Task {
            do {
                
                let session = try? await SupabaseService.shared.client.auth.session

                try await SupabaseService.shared.client
                    .from("support_messages")
                    .insert([
                        "user_id": session?.user.id.uuidString ?? "",  
                        "user_email": session?.user.email ?? "anonymous",
                        "message": messageText,
                        "app_version": "\(AppInfo.version) (\(AppInfo.build))",
                        "ios_version": UIDevice.current.systemVersion,
                        "device_model": DeviceInfo.modelName
                    ])
                    .execute()
                
                await MainActor.run {
                    messageText = ""
                    alertMessage = String(localized: "support_success_message")
                    showAlert = true
                }
                
            } catch {
                
                await MainActor.run {
                    alertMessage = String(localized: "support_error_message")
                    showAlert = true
                }
                
                print("Support sending error:", error)
            }
        }
    }
}

#Preview {
    SupportView()
        .environmentObject(AppCoordinator())
}

