import SwiftUI

struct ChatRoomView: View {
    let chat: Chat

    @StateObject private var viewModel: ChatRoomViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var showRatingSheet = false
    @State private var ratingStep: RatingStep = .stars

    private var order: Order? { chat.cachedOrder }
    private var isChatClosed: Bool {
        guard let status = order?.status else { return false }
        return status == "delivered" || status == "cancelled"
    }
    private var detentsForStep: Set<PresentationDetent> {
        switch ratingStep {
        case .stars:                    return [.height(420)]
        case .tags:                     return [.height(670)]
        case .comment, .commentWithPhoto: return [.height(560)]
        }
    }

    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(chatId: chat.id))
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if let order = order {
                orderInfoCard(order)
            }

            ZStack {
                Color(hex: "F7F7F7").ignoresSafeArea(edges: .bottom)

                if viewModel.isLoading && viewModel.messages.isEmpty {
                    ProgressView()
                } else {
                    messagesList
                }
            }

            if isChatClosed {
                closedChatBar
            } else {
                messageInputBar
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchMessages()
            await viewModel.markMessagesAsRead()
            viewModel.subscribeToMessages()
        }
        .onDisappear {
            viewModel.unsubscribe()
        }
        .sheet(isPresented: $showRatingSheet) {
            if let order = order {
                RatingSheet(
                    order: order,
                    imageURL: URL(string: order.items.first?.productImageUrl ?? ""),
                    currentStep: $ratingStep
                )
                .presentationDetents(detentsForStep)
                .presentationDragIndicator(.visible)
                .onChange(of: showRatingSheet) { isShowing in
                    if !isShowing { ratingStep = .stars }
                }
            }
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        ZStack {
            Image("locationTopBackground")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .ignoresSafeArea(edges: .top)

            HStack(spacing: 12) {
                Button(action: { coordinator.chatsPath.removeLast() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                ZStack {
                    Circle()
                        .fill(Color(hex: chat.avatarColor))
                        .frame(width: 40, height: 40)
                    Text(chat.avatarLetter)
                        .font(.onest(.semiBold, size: 17))
                        .foregroundColor(.black.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(chat.sellerName)
                            .font(.onest(.bold, size: 16))
                            .foregroundColor(.black)
                        if chat.isSellerVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "9AF19A"))
                        }
                    }
                    Text("chat_response_time")
                        .font(.onest(.regular, size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .frame(height: 64)
    }

    // MARK: - Order Info Card

    private func orderInfoCard(_ order: Order) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: order.items.first?.productImageUrl ?? "")) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Image(.appLogo).resizable().scaledToFit().padding(6)
                        .background(Color(hex: "F2F2F2"))
                }
            }
            .frame(width: 48, height: 48)
            .cornerRadius(10)
            .clipped()

            VStack(alignment: .leading, spacing: 3) {
                Text(order.items.first?.productTitle ?? order.shopName)
                    .font(.onest(.semiBold, size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(order.formattedTotal)
                        .font(.onest(.regular, size: 12))
                        .foregroundColor(.gray)
                    if let window = order.formattedDeliveryWindow {
                        Text("•").foregroundColor(.gray)
                        Text(String(localized: "order_delivery_label") + " " + window)
                            .font(.onest(.regular, size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "F2F2F2")),
            alignment: .bottom
        )
    }

    // MARK: - Messages List

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    securityNotice
                        .padding(.vertical, 20)

                    ForEach(groupedMessages, id: \.0) { date, messages in
                        dateSeparator(date: date, firstMessage: messages.first)
                            .padding(.bottom, 8)

                        ForEach(messages) { message in
                            MessageBubble(message: message, isMine: isMyMessage(message))
                                .padding(.bottom, 4)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .onChange(of: viewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Security Notice

    private var securityNotice: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "9AF19A"))

            Text("chat_security_title")
                .font(.onest(.semiBold, size: 13))
                .foregroundColor(.black)

            Text("chat_security_subtitle")
                .font(.onest(.regular, size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Date Separator

    private func dateSeparator(date: Date, firstMessage: Message?) -> some View {
        let calendar = Calendar.current
        var label: String
        if calendar.isDateInToday(date) {
            label = String(localized: "chat_today")
        } else if calendar.isDateInYesterday(date) {
            label = String(localized: "chat_yesterday")
        } else {
            let f = DateFormatter()
            f.locale = Locale(identifier: "uk_UA")
            f.dateFormat = "d MMMM"
            label = f.string(from: date)
        }
        if let msg = firstMessage {
            let tf = DateFormatter()
            tf.dateFormat = "HH:mm"
            label += ", \(tf.string(from: msg.createdAt))"
        }
        return Text(label)
            .font(.onest(.regular, size: 12))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Input Bar

    private var messageInputBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            HStack(alignment: .bottom, spacing: 8) {
                TextField(
                    String(localized: "chats_message_placeholder"),
                    text: $viewModel.messageText,
                    axis: .vertical
                )
                .font(.onest(.regular, size: 16))
                .lineLimit(1...5)
                .padding(.leading, 16)
                .padding(.vertical, 12)

                HStack(spacing: 12) {
                    if viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button(action: {}) {
                            Image(systemName: "camera")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                        Button(action: {}) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button(action: { Task { await viewModel.sendMessage() } }) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 34, height: 34)
                                .background(Color(hex: "9AF19A"))
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.isSending)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            }
            .background(Color(hex: "F2F2F2"))
            .cornerRadius(24)
            .animation(.easeInOut(duration: 0.15),
                       value: viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.06), radius: 8, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Closed Chat Bar

    private var closedChatBar: some View {
        VStack(spacing: 12) {
            Divider()
            VStack(spacing: 4) {
                Text("chat_closed_title")
                    .font(.onest(.semiBold, size: 14))
                    .foregroundColor(.black)
                Text("chat_closed_subtitle")
                    .font(.onest(.regular, size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)

            if order?.status == "delivered", let order = order, order.review == nil {
                Button(action: { showRatingSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "star")
                            .font(.system(size: 15))
                        Text("chat_rate_order")
                            .font(.onest(.medium, size: 16))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "B8EEA6"))
                    .cornerRadius(26)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 24)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Helpers

    private var groupedMessages: [(Date, [Message])] {
        let grouped = Dictionary(grouping: viewModel.messages) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }
        return grouped.sorted { $0.key < $1.key }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = viewModel.messages.last {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    private func isMyMessage(_ message: Message) -> Bool {
        guard let uid = SupabaseService.shared.client.auth.currentUser?.id else { return false }
        return message.senderId == uid
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: Message
    let isMine: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isMine { Spacer(minLength: 64) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 3) {
                // Image attachment
                if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                                .frame(maxWidth: 220)
                                .frame(height: 160)
                                .cornerRadius(16, corners: isMine
                                    ? [.topLeft, .topRight, .bottomLeft]
                                    : [.topLeft, .topRight, .bottomRight])
                                .clipped()
                        default:
                            Color(hex: "F2F2F2")
                                .frame(width: 180, height: 140)
                                .cornerRadius(16)
                        }
                    }
                }

                // Text
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .font(.onest(.regular, size: 15))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isMine ? Color(hex: "B8EEA6") : Color.white)
                        .cornerRadius(18, corners: isMine
                            ? [.topLeft, .topRight, .bottomLeft]
                            : [.topLeft, .topRight, .bottomRight])
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                }

                // Timestamp
                Text(message.createdAt.formatted(.dateTime.hour().minute()))
                    .font(.onest(.regular, size: 11))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }

            if !isMine { Spacer(minLength: 64) }
        }
    }
}

// MARK: - RoundedCorner helper (specific corners)

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(ChatRoundedCorner(radius: radius, corners: corners))
    }
}

private struct ChatRoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}
