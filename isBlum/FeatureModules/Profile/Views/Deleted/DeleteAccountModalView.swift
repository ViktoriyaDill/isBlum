//
//  DeleteAccountModalView.swift
//  isBlum
//
//  Created by Пользователь on 09/03/2026.
//

import Foundation
import SwiftUI

// MARK: - Navigation State
enum DeleteAccountStep {
    case main
    case selectReason
}

// MARK: - Deletion Reason Model
struct DeletionReason: Identifiable, Hashable {
    let id = UUID()
    let text: String
}

struct DeleteAccountModalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var currentStep: DeleteAccountStep = .main
    @State private var selectedReason: DeletionReason?
    @State private var isDeleting = false
    
    // Predefined reasons from the screenshot
    let reasons = [
        DeletionReason(text: "delete_reason_found_another"),
        DeletionReason(text: "delete_reason_inconvenient"),
        DeletionReason(text: "delete_reason_quality"),
        DeletionReason(text: "delete_reason_temporary"),
        DeletionReason(text: "delete_reason_other")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Drag handle and Close button
            header
            
            ZStack(alignment: .top) {
                if currentStep == .main {
                    mainWarningView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity
                        ))
                } else {
                    reasonsSelectionView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .presentationDetents(currentStep == .main ? [.medium] : [.large])
        .presentationDragIndicator(.visible)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
    }
}

// MARK: - Subviews
extension DeleteAccountModalView {
    
    private var header: some View {
        HStack {
            Spacer()
            
            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.15))
            }
        }
        .padding([.horizontal, .top], 20)
        
    }
    
    // First View: Warning
    private var mainWarningView: some View {
        VStack(spacing: 16) {
            Image(.deleteIllustration)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            Text("delete_account_title")
                .font(.onest(.bold, size: 24))

            Text("delete_account_description")
                .font(.onest(.regular, size: 16))
                .foregroundColor(Color(hex: "#535852"))
                .multilineTextAlignment(.center)
            
            // Button to open reasons
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentStep = .selectReason
                }
            }) {
                HStack {
                    Text(LocalizedStringResource(stringLiteral: selectedReason?.text ?? "delete_account_select_reason"))
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#D4D5D4")))
            }
            .padding(.top, 8)
            
            actionButtons
        }
    }
    
    // Second View: Reasons List
    private var reasonsSelectionView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("delete_account_reason_title")
                    .font(.onest(.bold, size: 24))
                    .multilineTextAlignment(.center)

                Text("delete_account_reason_subtitle")
                    .font(.onest(.regular, size: 16))
                    .foregroundColor(Color(hex: "#535852"))
            }
            
            VStack(spacing: 16) {
                ForEach(reasons) { reason in
                    Button(action: { selectedReason = reason }) {
                        HStack {
                            Text("\(LocalizedStringResource(stringLiteral: reason.text))")
                                .font(.onest(.regular, size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            // Radio button logic
                            ZStack {
                                Circle()
                                    .stroke(selectedReason == reason ? Color.black : Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                
                                if selectedReason == reason {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    if reason != reasons.last {
                        Divider()
                    }
                }
            }
            
            actionButtons
                .padding(.top, 16)
        }
    }
    
    private var actionButtons: some View {
        VStack(alignment: .center, spacing: 12) {
            Button(action: { dismiss() }) {
                Text("delete_account_cancel")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#F4F4F4"))
                    .cornerRadius(30)
            }

            Button(action: handleDelete) {
                Text("delete_account_confirm")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(Color(hex: "D71616"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "FEF6F6"))
                    .cornerRadius(30)
            }
        }
        .padding(.bottom, 16)
    }
    
    private func handleDelete() {
        isDeleting = true
        Task {
            await auth.deleteAccount(reason: selectedReason?.text)
            isDeleting = false
            
            if auth.authError == nil {
                dismiss()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    coordinator.profilePath = NavigationPath()
                    coordinator.profilePath.append(AppRoute.accountDeletedSuccess)
                }
            }
        }
    }
}
