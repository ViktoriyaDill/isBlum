//
//  FilterPriceView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct FilterPriceView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var filterVM: FilterViewModel
    
    // Slider range
    private let minLimit: Double = 0
    private let maxLimit: Double = 15000
    
    // Quick select presets
    private let presets: [(title: String, min: Int, max: Int)] = [
        ("До 1000 грн", 0, 1000),
        ("1000 – 2000 грн", 1000, 2000),
        ("2000 – 3000 грн", 2000, 3000),
        (">3000 грн", 3000, 15000)
    ]
    
    // Local state for text fields
    @State private var minText: String = ""
    @State private var maxText: String = ""
    
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
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("Вкажіть вартість")
                        .font(.onest(.bold, size: 24))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    // MARK: - Slider
                    VStack(spacing: 4) {
                        RangeSliderView(
                            minValue: Binding(
                                get: { Double(filterVM.priceMin) },
                                set: { filterVM.priceMin = Int($0); minText = "\(Int($0))" }
                            ),
                            maxValue: Binding(
                                get: { Double(filterVM.priceMax) },
                                set: { filterVM.priceMax = Int($0); maxText = "\(Int($0))" }
                            ),
                            range: minLimit...maxLimit
                        )
                        
                        HStack {
                            Text("0 грн")
                                .font(.onest(.regular, size: 12))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("15000+ грн")
                                .font(.onest(.regular, size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // MARK: - Min/Max inputs
                    HStack(spacing: 12) {
                        PriceInputField(label: "Мінімум", text: $minText)
                            .onChange(of: minText) { val in
                                if let v = Int(val) {
                                    filterVM.priceMin = min(v, filterVM.priceMax)
                                }
                            }
                        
                        PriceInputField(label: "Максимум", text: $maxText)
                            .onChange(of: maxText) { val in
                                if let v = Int(val) {
                                    filterVM.priceMax = max(v, filterVM.priceMin)
                                }
                            }
                    }
                    
                    // MARK: - Presets
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(presets, id: \.title) { preset in
                            let isSelected = filterVM.priceMin == preset.min && filterVM.priceMax == preset.max
                            
                            Button(action: {
                                filterVM.priceMin = preset.min
                                filterVM.priceMax = preset.max
                                minText = "\(preset.min)"
                                maxText = "\(preset.max)"
                            }) {
                                Text(preset.title)
                                    .font(.onest(.medium, size: 14))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(isSelected ? Color(hex: "9AF19A") : Color(hex: "F2F2F2"))
                                    .cornerRadius(22)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
        .onAppear {
            minText = "\(filterVM.priceMin)"
            maxText = "\(filterVM.priceMax)"
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                filterVM.save()
                coordinator.finishFilters()
            }) {
                Text("Показати букети")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "9AF19A"))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }
}

// MARK: - Price Input Field
struct PriceInputField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.onest(.regular, size: 12))
                .foregroundColor(.gray)
            
            HStack {
                TextField("0", text: $text)
                    .font(.onest(.medium, size: 20))
                    .keyboardType(.numberPad)
                
                Text("грн")
                    .font(.onest(.regular, size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryBorder, lineWidth: 1.5)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Range Slider
struct RangeSliderView: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let totalRange = range.upperBound - range.lowerBound
            let minX = (minValue - range.lowerBound) / totalRange * width
            let maxX = (maxValue - range.lowerBound) / totalRange * width
            
            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color(hex: "F2F2F2"))
                    .frame(height: 4)
                
                // Active track
                Capsule()
                    .fill(Color.black)
                    .frame(width: maxX - minX, height: 4)
                    .offset(x: minX)
                
                // Min thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .offset(x: minX - 14)
                    .gesture(DragGesture().onChanged { drag in
                        let newVal = range.lowerBound + drag.location.x / width * totalRange
                        minValue = min(max(newVal, range.lowerBound), maxValue - 500)
                    })
                
                // Max thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .offset(x: maxX - 14)
                    .gesture(DragGesture().onChanged { drag in
                        let newVal = range.lowerBound + drag.location.x / width * totalRange
                        maxValue = max(min(newVal, range.upperBound), minValue + 500)
                    })
            }
        }
        .frame(height: 28)
    }
}

#Preview {
    FilterPriceView()
        .environmentObject(AppCoordinator())
        .environmentObject(FilterViewModel())
}
