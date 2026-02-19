//
//  FilterFlowersView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct FilterFlowersView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var filterVM: FilterViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private let flowers = [
        FlowerModel(title: "Будь-які квіти", iconName: "any_flowers"),
        FlowerModel(title: "Рози", iconName: "roses"),
        FlowerModel(title: "Піони", iconName: "peonies"),
        FlowerModel(title: "Тюльпани", iconName: "tulips"),
        FlowerModel(title: "Хризантеми", iconName: "chrysanthemums"),
        FlowerModel(title: "Еустома", iconName: "eustoma"),
        FlowerModel(title: "Гортензія", iconName: "hydrangea")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Фільтри", showBackButton: true) {
                coordinator.goBack()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 32) {
                    Text("Які квіти в букеті?")
                        .font(.onest(.bold, size: 24))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(flowers) { flower in
                            OccasionCard(
                                occasion: OccasionModel(title: flower.title, iconName: flower.iconName),
                                isSelected: filterVM.isFlowerSelected(flower.title)
                            ) {
                                if flower.title == "Будь-які квіти" {
                                    filterVM.selectedFlowers = ["Будь-які квіти"]
                                } else {
                                    filterVM.selectedFlowers.remove("Будь-які квіти")
                                    filterVM.toggleFlower(flower.title)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            filterVM.save()
                            coordinator.showNextFilter(from: .filterFlowers)
                        }) {
                            Text("Далі")
                                .font(.onest(.medium, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "9AF19A"))
                                .cornerRadius(28)
                        }
                        .disabled(filterVM.selectedFlowers.isEmpty)
                        .opacity(filterVM.selectedFlowers.isEmpty ? 0.6 : 1.0)
                        
                        Button(action: {
                            coordinator.showNextFilter(from: .filterFlowers)
                        }) {
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
}

struct FlowerModel: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

#Preview {
    FilterFlowersView()
        .environmentObject(AppCoordinator())
        .environmentObject(FilterViewModel())
}
