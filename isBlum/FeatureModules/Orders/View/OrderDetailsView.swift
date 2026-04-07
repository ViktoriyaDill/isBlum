//
//  OrderDetailsView.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 01/04/2026.
//

import Foundation
import SwiftUI

// MARK: - Scroll Offset Preference Key

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct OrderDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var isCopied: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showCancelSheet: Bool = false
    @State private var showCancelledState: Bool = false
    @State private var showingRatingSheet = false
    @State private var ratingStep: RatingStep = .stars
    @State private var isFetchingChat = false

    let order: Order

    private var detentsForStep: Set<PresentationDetent> {
        switch ratingStep {
        case .stars:              return [.height(420)]
        case .tags:               return [.height(670)]
        case .comment, .commentWithPhoto: return [.height(560)]
        }
    }

    // 0→1 поки hero іде вгору (перші 80pt скролу) — для фону nav bar і кола кнопки бек
    private var navBarProgress: CGFloat {
        max(0, min(1, -scrollOffset / 80))
    }

    // 0→1 коли великий заголовок ховається за nav bar (100–150pt)
    private var titleProgress: CGFloat {
        max(0, min(1, (-scrollOffset - 100) / 50))
    }

    // MARK: - Computed nav title content

    private var deliverySubtitle: String? {
        if let window = order.formattedDeliveryWindow {
            return String(localized: "order_delivery_label") + " \(window)"
        } else if order.status == "preparing" || order.status == "pending" {
            return String(localized: "order_est_time")
        }
        return nil
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Anchor для відстеження позиції скролу
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: geo.frame(in: .named("orderDetailsScroll")).minY
                        )
                }
                .frame(height: 0)

                heroImage

                VStack(spacing: 12) {

                    // БЛОК 1: Основна інформація
                    VStack(alignment: .leading, spacing: 0) {
                        titleStatusSection
                            .padding(.top, 20)

                        chatButton
                            .padding(.top, 16)

                        ratingSection
                            .padding(.top, 4)

                        deliveryPathSection
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(24)

                    // БЛОК 2: Деталі замовлення (ціни, номер)
                    VStack(alignment: .leading, spacing: 0) {
                        orderDetailsSection
                            .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(24)

                    // БЛОК 3: Підтримка та скасування
                    VStack(alignment: .leading, spacing: 0) {
                        supportSection
                            .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(24)

                    Color.clear.frame(height: 40)
                }
                .offset(y: -24)
            }
        }
        .coordinateSpace(name: "orderDetailsScroll")
        .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }
        .background(Color(hex: "#F4F4F4").ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                navBackButton
            }
            ToolbarItem(placement: .principal) {
                navPrincipalTitle
            }
        }
        .toolbarBackground(navBarProgress > 0.5 ? .visible : .hidden, for: .navigationBar)
        .toolbarBackground(Color.white, for: .navigationBar)
        .animation(.easeInOut(duration: 0.2), value: navBarProgress > 0.5)
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
        // MARK: Cancel confirmation sheet
        .sheet(isPresented: $showCancelSheet) {
            CancelOrderSheet(
                cancelAction: {
                    try await SupabaseService.shared.client
                        .from("orders")
                        .update(["status": "cancelled"])
                        .eq("id", value: order.id.uuidString)
                        .execute()
                },
                onChat: {
                    Task { await navigateToChat() }
                },
                onCancelled: {
                    showCancelledState = true
                }
            )
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
        }
        // MARK: Cancelled success full-screen
        .fullScreenCover(isPresented: $showCancelledState) {
            OrderCancelledView {
                showCancelledState = false
                dismiss()
            }
        }
    }

    // MARK: - Nav Bar Items

    // Біле коло над фото → плавно зникає коли nav bar стає білим
    private var navBackButton: some View {
        Button(action: { dismiss() }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .opacity(1 - navBarProgress)
                    .frame(width: 36, height: 36)
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }

    // Назва + час доставки по центру — з'являється коли великий заголовок ховається
    private var navPrincipalTitle: some View {
        VStack(spacing: 1) {
            Text(order.items.first?.productTitle ?? String(localized: "order_default_title"))
                .font(.onest(.bold, size: 15))
                .foregroundColor(.black)
                .lineLimit(1)
            if let subtitle = deliverySubtitle {
                Text(subtitle)
                    .font(.onest(.regular, size: 12))
                    .foregroundColor(.gray)
            }
        }
        .opacity(titleProgress)
    }
    
    // MARK: - Hero Image
    
    private var heroImage: some View {
        AsyncImage(url: URL(string: order.items.first?.productImageUrl ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                    .background(Color(hex: "#F2F2F2"))
            @unknown default:
                Color(hex: "#F2F2F2")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipped()
    }
    
    // MARK: - Title & Status
    
    private var titleStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(order.items.first?.productTitle ?? "Замовлення")
                .font(.onest(.bold, size: 24))
                .foregroundColor(.black)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                statusBadge(order.statusDisplay)
                
                if let window = order.formattedDeliveryWindow {
                    Text("• " + "order_delivery_label" + " \(window)")
                        .font(.onest(.regular, size: 13))
                        .foregroundColor(.gray)
                } else if order.status == "preparing" || order.status == "pending" {
                    (Text("• ") + Text("order_est_time"))
                        .font(.onest(.regular, size: 13))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Chat Navigation

    private func navigateToChat() async {
        guard !isFetchingChat,
              let userId = SupabaseService.shared.client.auth.currentUser?.id else { return }
        isFetchingChat = true
        defer { isFetchingChat = false }

        do {
            let client = SupabaseService.shared.client

            struct ChatRow: Decodable {
                let id: UUID
                let clientId: UUID
                let sellerId: UUID
                let orderId: UUID?
                let lastMessage: String?
                let lastMessageAt: Date?
                let createdAt: Date
                enum CodingKeys: String, CodingKey {
                    case id
                    case clientId = "client_id"
                    case sellerId = "seller_id"
                    case orderId = "order_id"
                    case lastMessage = "last_message"
                    case lastMessageAt = "last_message_at"
                    case createdAt = "created_at"
                }
            }

            struct NewChat: Encodable {
                let clientId: UUID
                let sellerId: UUID
                let orderId: UUID
                enum CodingKeys: String, CodingKey {
                    case clientId = "client_id"
                    case sellerId = "seller_id"
                    case orderId = "order_id"
                }
            }

            // Upsert — returns existing or newly created row
            let rows: [ChatRow] = try await client
                .from("chats")
                .upsert(
                    NewChat(clientId: userId, sellerId: order.sellerId, orderId: order.id),
                    onConflict: "client_id,seller_id,order_id"
                )
                .select("id, client_id, seller_id, order_id, last_message, last_message_at, created_at")
                .execute()
                .value

            guard let row = rows.first else { return }

            var chat = Chat(
                id: row.id,
                clientId: row.clientId,
                sellerId: row.sellerId,
                orderId: row.orderId,
                lastMessage: row.lastMessage,
                lastMessageAt: row.lastMessageAt,
                createdAt: row.createdAt
            )
            chat.sellerName = order.sellerProfile?.shopName ?? order.shopName
            chat.isSellerVerified = order.sellerProfile?.isVerified ?? false

            coordinator.showChatRoom(chat)
        } catch {
            print("navigateToChat error:", error)
        }
    }

    // MARK: - Chat Button

    private var chatButton: some View {
        Button(action: { Task { await navigateToChat() } }) {
            HStack(spacing: 8) {
                Image(.bubble)
                    .font(.system(size: 15))
                Text("order_chat_with_shop")
                    .font(.onest(.medium, size: 16))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: "#F4F4F4"))
            .cornerRadius(26)
        }
    }

    // MARK: - Rating Section

    @ViewBuilder
    private var ratingSection: some View {
        if let review = order.review {
            HStack(spacing: 6) {
                Text(String(format: "%.1f", Double(review.rating)))
                    .font(.onest(.semiBold, size: 16))
                    .foregroundColor(.black)
                Image(.rateOrderStar1)
                    .foregroundColor(Color(hex: "#F5C518"))
                    .font(.system(size: 15))
                Text("order_your_rating_text")
                    .font(.onest(.regular, size: 16))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        } else if order.status == "delivered" {
            Button(action: { showingRatingSheet = true }) {
                HStack(spacing: 8) {
                    Image(.rateOrderStar)
                        .font(.system(size: 15))
                    Text("order_rate_title")
                        .font(.onest(.medium, size: 16))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
        }
    }

    // MARK: - Shop & Delivery Combined Section

    private var deliveryPathSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Секція магазину
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    
                    Image(.geolocationPin)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    VStack(spacing: 0) {
                        Path { path in
                            path.move(to: CGPoint(x: 1, y: 0))
                            path.addLine(to: CGPoint(x: 1, y: 30))                         }
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .foregroundColor(Color(hex: "#F4F4F4"))
                        .frame(width: 2, height: 30)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("order_from_shop_label")
                        .font(.onest(.regular, size: 13))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(.messageShopLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .background(Color.white)
                            .clipShape(Circle())
                        
                        Text(order.shopName)
                            .font(.onest(.semiBold, size: 16))
                            .foregroundColor(.black)
                        
                        if order.sellerProfile?.isVerified == true {
                            Image(.verified)
                                .foregroundColor(Color(hex: "#4CAF50"))
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(.top, 2)
            }
            
            HStack(alignment: .top, spacing: 12) {
                Image(.deliveryLocation)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("order_delivery_address_label")
                        .font(.onest(.regular, size: 13))
                        .foregroundColor(.gray)
                    
                    Text(order.deliveryAddress ?? "—")
                        .font(.onest(.medium, size: 15))
                        .foregroundColor(.black)
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Dashed Divider
    
    private var dashedDivider: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .frame(height: 1)
            .foregroundColor(Color.gray.opacity(0.25))
    }
    
    // MARK: - Order Details Section
    
    private var orderDetailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("order_details_section_title")
                .font(.onest(.bold, size: 16))
                .foregroundColor(.black)
                .padding(.bottom, 16)
            
            // Order number
            HStack {
                Text("order_number_label")
                    .font(.onest(.regular, size: 16))
                    .foregroundColor(Color(hex: "#535852"))
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(order.shortId)
                        .font(.onest(.medium, size: 14))
                        .foregroundColor(.black)
                    
                    Button(action: {
                        UIPasteboard.general.string = order.shortId
                        
                        withAnimation {
                            isCopied = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isCopied = false
                            }
                        }
                    }) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(isCopied ? Color(hex: "#4CAF50") : .gray)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#F4F4F4"))
                .cornerRadius(8)
            }
            .padding(.bottom, 12)
            
            // Date
            HStack {
                Text("order_date_label")
                    .font(.onest(.regular, size: 16))
                    .foregroundColor(Color(hex: "#535852"))
                Spacer()
                Text(order.formattedCreatedAt)
                    .font(.onest(.medium, size: 14))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 12)
            
            // Subtotal
            if let subtotal = order.subtotal {
                HStack {
                    Text("order_subtotal_label")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(Color(hex: "#535852"))
                    Spacer()
                    Text("\(Int(subtotal)) грн")
                        .font(.onest(.medium, size: 14))
                        .foregroundColor(.black)
                }
                .padding(.bottom, 12)
            }
            
            // Delivery fee
            if let fee = order.deliveryFee {
                HStack {
                    Text("order_delivery_fee_label")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(Color(hex: "#535852"))
                    Spacer()
                    Text(fee == 0 ? "order_free_delivery" : "\(Int(fee)) грн")
                        .font(.onest(.medium, size: 14))
                        .foregroundColor(fee == 0 ? Color(hex: "#4CAF50") : .black)
                }
                .padding(.bottom, 12)
            }
            
            // Dashed divider
            dashedDivider
                .padding(.bottom, 16)
            
            // Total
            HStack {
                Text("order_total_label")
                    .font(.onest(.bold, size: 16))
                    .foregroundColor(.black)
                Spacer()
                Text(order.formattedTotal)
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 12)
            
            // Payment method (placeholder)
            HStack {
                HStack(spacing: 6) {
                    Image(.creditcard)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    Text("order_payment_method_label")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(Color(hex: "#535852"))
                }
                Spacer()
                Text("order_payment_card")
                    .font(.onest(.medium, size: 14))
                    .foregroundColor(.black)
            }
        }
    }
    
    // MARK: - Support Section
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("order_trouble_title")
                .font(.onest(.bold, size: 16))
                .foregroundColor(.black)
            
            // Contact support button
            Button(action: { coordinator.showSupportFromOrders() }) {
                HStack(spacing: 8) {
                    Image(.supportChat)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("order_contact_support_button")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(hex: "#F4F4F4"))
                .cornerRadius(26)
            }
            
            // Cancel order button — відкриває шит підтвердження
            if order.status == "pending" || order.status == "confirmed" {
                Button(action: { showCancelSheet = true }) {
                    Text("order_cancel_button")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(Color(hex: "#E53935"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#FFF0F0"))
                        .cornerRadius(26)
                }
            }
            
            // Info note
            HStack(spacing: 4) {
                Image(.info)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text("order_cancel_info_note")
                    .font(.onest(.regular, size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    // MARK: - Status Badge
    
    private func statusBadge(_ display: (text: String, textColor: String, color: String, icon: String)) -> some View {
        HStack(spacing: 6) {
            Image(display.icon)
                .font(.system(size: 11, weight: .bold))
            Text(display.text)
                .font(.onest(.medium, size: 12))
        }
        .foregroundColor(Color(hex: display.textColor))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(hex: display.color))
        .cornerRadius(10)
    }
}

// MARK: - Rounded Corner Shape

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
