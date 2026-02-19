//
//  FiltersView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct FiltersView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var filterVM: FilterViewModel
    
    // Grid settings
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // Sample data
    private let occasions = [
        OccasionModel(title: "Без приводу", iconName: "gift_icon"),
        OccasionModel(title: "День народження", iconName: "cake_icon"),
        OccasionModel(title: "Весілля", iconName: "rings_icon"),
        OccasionModel(title: "Випускний", iconName: "grad_icon"),
        OccasionModel(title: "Співчуття", iconName: "flower_icon"),
        OccasionModel(title: "Інший привід", iconName: "other_icon")
    ]
    
    // Multiple selection state
    @State private var selectedOccasions = Set<UUID>()

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Фільтри", showBackButton: false) {
                coordinator.goBack()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 32) {
                    Text("Для якого приводу букет?")
                        .font(.onest(.bold, size: 24))
                        .padding(.top, 40)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(occasions) { occasion in
                            OccasionCard(
                                occasion: occasion,
                                isSelected: selectedOccasions.contains(occasion.id)
                            ) {
                                toggleSelection(for: occasion.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            filterVM.save()
                            coordinator.showNextFilter(from: .filterOccasion)
                            print("Applying filters for IDs: \(selectedOccasions)")
                        }) {
                            Text("Далі")
                                .font(.onest(.medium, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "9AF19A"))
                                .cornerRadius(28)
                        }
                        .disabled(selectedOccasions.isEmpty)
                        .opacity(selectedOccasions.isEmpty ? 0.6 : 1.0)
                        
                        Button(action: { coordinator.showNextFilter(from: .filterOccasion) }) {
                            Text("Пропустити")
                                .font(.onest(.medium, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "F2F2F2"))
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
    }
    
    // Toggle logic
    private func toggleSelection(for id: UUID) {
        if selectedOccasions.contains(id) {
            selectedOccasions.remove(id)
        } else {
            selectedOccasions.insert(id)
        }
    }
}

// Subview for the occasion cell
struct OccasionCard: View {
    let occasion: OccasionModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    if isSelected {
                        // Checkmark on green background
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color(hex: "9AF19A"))
                            .font(.system(size: 24))
                    } else {
                        // Simple gray plus
                        Image(systemName: "plus.circle")
                            .foregroundColor(.gray.opacity(0.3))
                            .font(.system(size: 24))
                    }
                }
                .padding([.top, .trailing], 8)
                
                Image(occasion.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                Text(occasion.title)
                    .font(.onest(.regular, size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 4)
                
                Spacer(minLength: 0)
            }
            .frame(height: 110)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "9AF19A") : Color.gray.opacity(0.1), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Avoid default dimming
    }
}

#Preview {
    FiltersView().environmentObject(AppCoordinator())
}
