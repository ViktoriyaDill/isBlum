//
//  CancelOrderSheet.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 06/04/2026.
//

import SwiftUI

struct CancelOrderSheet: View {

    /// Асинхронна дія скасування — кидає помилку якщо запит не вдався
    let cancelAction: () async throws -> Void
    /// Відкрити чат з магазином
    let onChat: () -> Void
    /// Викликається після успішного скасування (через 0.35 с після закриття шита)
    let onCancelled: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isCancelling = false

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Close button
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F4F4F4"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // MARK: Illustration
            Image(.flowerCancel)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 120)
                .padding(.top, 8)

            // MARK: Title
            Text("order_cancel_confirm_title")
                .font(.onest(.bold, size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            // MARK: Description
            Text("order_cancel_sheet_message")
                .font(.onest(.regular, size: 15))
                .foregroundColor(Color(hex: "#535852"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 10)

            Spacer()

            // MARK: Chat button
            Button {
                dismiss()
                onChat()
            } label: {
                HStack(spacing: 8) {
                    Image(.bubble)
                    Text("order_chat_with_shop")
                        .font(.onest(.medium, size: 16))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(hex: "#F4F4F4"))
                .cornerRadius(26)
            }
            .padding(.horizontal, 20)

            // MARK: Cancel button
            Button {
                guard !isCancelling else { return }
                Task {
                    isCancelling = true
                    do {
                        try await cancelAction()
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            onCancelled()
                        }
                    } catch {
                        isCancelling = false
                    }
                }
            } label: {
                Group {
                    if isCancelling {
                        ProgressView()
                    } else {
                        Text("order_cancel_button")
                            .font(.onest(.medium, size: 16))
                            .foregroundColor(Color(hex: "#E53935"))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(hex: "#FFF0F0"))
                .cornerRadius(26)
            }
            .disabled(isCancelling)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
    }
}
