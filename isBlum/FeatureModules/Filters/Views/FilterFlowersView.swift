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
        FlowerModel(filterKey: "Будь-які квіти", title: "filter_flower_any", iconName: "any_flowers"),
        FlowerModel(filterKey: "Рози", title: "filter_flower_roses", iconName: "roses"),
        FlowerModel(filterKey: "Піони", title: "filter_flower_peonies", iconName: "peonies"),
        FlowerModel(filterKey: "Тюльпани", title: "filter_flower_tulips", iconName: "tulips"),
        FlowerModel(filterKey: "Хризантеми", title: "filter_flower_chrysanthemums", iconName: "chrysanthemums"),
        FlowerModel(filterKey: "Еустома", title: "filter_flower_eustoma", iconName: "eustoma"),
        FlowerModel(filterKey: "Гортензія", title: "filter_flower_hydrangea", iconName: "hydrangea")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "filter_nav_title", showBackButton: true) {
                coordinator.goBack()
            }
            .background(Color(hex: "E2F5C6"))

            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 32) {
                    Text("filter_flowers_title")
                        .font(.onest(.bold, size: 24))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(flowers) { flower in
                            OccasionCard(
                                occasion: OccasionModel(title: flower.title, iconName: flower.iconName),
                                isSelected: filterVM.isFlowerSelected(flower.filterKey)
                            ) {
                                if flower.filterKey == "Будь-які квіти" {
                                    filterVM.selectedFlowers = ["Будь-які квіти"]
                                } else {
                                    filterVM.selectedFlowers.remove("Будь-які квіти")
                                    filterVM.toggleFlower(flower.filterKey)
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
                            Text("filter_next_button")
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
                            Text("filter_skip_button")
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
    let filterKey: String
    let title: LocalizedStringKey
    let iconName: String
}

#Preview {
    FilterFlowersView()
        .environmentObject(AppCoordinator())
        .environmentObject(FilterViewModel())
}
