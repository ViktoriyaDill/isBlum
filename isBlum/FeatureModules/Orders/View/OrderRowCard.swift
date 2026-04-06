//
//  OrderRowCard.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 21/03/2026.
//

import Foundation
import SwiftUI

struct OrderRowCard: View {

    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showingRatingSheet = false
    @State private var ratingStep: RatingStep = .stars

    let order: Order
    
    private var detentsForStep: Set<PresentationDetent> {
            switch ratingStep {
            case .stars:   return [.height(420)]
            case .tags:    return [.height(670)]
            case .comment, .commentWithPhoto: return [.height(560)]
            }
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Try product image from order item first, fallback to logo
                AsyncImage(url: URL(string: order.items.first?.productImageUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image(.appLogo)
                            .resizable()
                            .scaledToFill()
                            .padding(8)
                            .background(Color(hex: "F2F2F2"))
                    @unknown default:
                        Color(hex: "F2F2F2")
                    }
                }
                .frame(width: 56, height: 56)
                .cornerRadius(12)
                .clipped()
                
                VStack(alignment: .leading, spacing: 6) {
                    // Заголовок товару
                    Text(order.items.first?.productTitle ?? String(localized: "order_default_title"))
                        .font(.onest(.bold, size: 16))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Text(order.formattedTotal)
                            .font(.onest(.regular, size: 13))
                            .foregroundColor(.gray)

                        if let window = order.formattedDeliveryWindow {
                            Text("•")
                                .foregroundColor(.gray)
                            Text(String(localized: "order_delivery_label") + " \n" + window)
                                .font(.onest(.regular, size: 13))
                                .foregroundColor(.gray)
                        } else if order.status == "preparing" || order.status == "pending" {
                            Text("• ") + Text("order_est_time")
                        }
                    }
                    .font(.onest(.regular, size: 13))
                    .foregroundColor(.gray)
                    
                    // Статус
                    statusBadge(order.statusDisplay)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Пунктирний розділювач (Dashed Line)
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2))
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
    
            HStack(spacing: 8) {
                Button(action: { coordinator.showOrderDetails(order) }) {
                    Text("orders_details_button")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: order.status == "delivered" ? .none : .infinity)
                        .padding(.horizontal, order.status == "delivered" ? 32 : 0)
                        .frame(height: 52)
                        .background(Color(hex: "#F4F4F4"))
                        .cornerRadius(26)
                }
                
                if order.status == "delivered" {
                    if let rating = order.review { 
                        HStack(spacing: 8) {
                            Text(String(format: "%.1f", Double(rating.rating)))
                                .font(.onest(.bold, size: 18))
                            
                            Image(.rateOrderStar1)
                                .foregroundColor(Color(hex: "#F2C94C"))
                                .font(.system(size: 18))
                            
                            Text("rating_your_rating")
                                .font(.onest(.medium, size: 16))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button(action: {
                            self.showingRatingSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(.rateOrderStar)
                                    .font(.system(size: 18))
                                Text("orders_rate_button")
                                    .font(.onest(.medium, size: 16))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "#F4F4F4"), lineWidth: 2)
        )
        .sheet(isPresented: $showingRatingSheet) {
                RatingSheet(
                    order: order,
                    imageURL: URL(string: order.items.first?.productImageUrl ?? ""),
                    currentStep: $ratingStep
                )
                .presentationDetents(detentsForStep)
                .presentationDragIndicator(.visible)
                .onChange(of: showingRatingSheet) { isShowing in
                    if !isShowing { ratingStep = .stars }
                }
            }
    }
    
    private func statusBadge(_ display: (text: String, textColor: String, color: String, icon: String)) -> some View {
            HStack(spacing: 6) {
                Image(display.icon)
                    .font(.system(size: 12, weight: .bold))
                
                Text(display.text)
                    .font(.onest(.medium, size: 13))
            }
            .foregroundColor(Color(hex: display.textColor))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: display.color))
            .cornerRadius(12)
        }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
