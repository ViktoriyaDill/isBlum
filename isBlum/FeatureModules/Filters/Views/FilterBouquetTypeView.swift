//
//  FilterBouquetTypeView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct FilterBouquetTypeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var filterVM: FilterViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private let bouquetTypes = [
        BouquetTypeModel(title: "Усі букети", iconName: "all_bouquets"),
        BouquetTypeModel(title: "Монобукет", iconName: "mono_bouquet"),
        BouquetTypeModel(title: "Преміум", iconName: "premium_bouquet"),
        BouquetTypeModel(title: "В коробці", iconName: "box_bouquet"),
        BouquetTypeModel(title: "Збірний", iconName: "mixed_bouquet")
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
                    Text("Який букет шукаємо?")
                        .font(.onest(.bold, size: 24))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(bouquetTypes) { type in
                            OccasionCard(
                                occasion: OccasionModel(title: type.title, iconName: type.iconName),
                                isSelected: filterVM.isBouquetTypeSelected(type.title)
                            ) {
                                
                                if type.title == "Усі букети" {
                                    filterVM.selectedBouquetTypes = ["Усі букети"]
                                } else {
                                    filterVM.selectedBouquetTypes.remove("Усі букети")
                                    filterVM.toggleBouquetType(type.title)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            filterVM.save()
                            coordinator.showNextFilter(from: .filterBouquetType)
                        }) {
                            Text("Далі")
                                .font(.onest(.medium, size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "9AF19A"))
                                .cornerRadius(28)
                        }
                        .disabled(filterVM.selectedBouquetTypes.isEmpty)
                        .opacity(filterVM.selectedBouquetTypes.isEmpty ? 0.6 : 1.0)
                        
                        Button(action: {
                            coordinator.showNextFilter(from: .filterBouquetType)
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

struct BouquetTypeModel: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

#Preview {
    FilterBouquetTypeView()
        .environmentObject(AppCoordinator())
        .environmentObject(FilterViewModel())
}
