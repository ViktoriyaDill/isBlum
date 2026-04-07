import SwiftUI

struct ChatRoomView: View {
    let chat: Chat

    @StateObject private var viewModel: ChatRoomViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(chatId: chat.id))
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ZStack {
                Color(hex: "F7F7F7")
                    .ignoresSafeArea(edges: .bottom)

                if viewModel.isLoading && viewModel.messages.isEmpty {
                    ProgressView()
                } else {
                    messagesList
                }
            }

            messageInputBar
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
                Button(action: {
                    coordinator.chatsPath.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                // Seller avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: chat.avatarColor))
                        .frame(width: 36, height: 36)
                    Text(chat.avatarLetter)
                        .font(.onest(.semiBold, size: 15))
                        .foregroundColor(.black.opacity(0.6))
                }

                HStack(spacing: 4) {
                    Text(chat.sellerName)
                        .font(.onest(.bold, size: 16))
                        .foregroundColor(.black)

                    if chat.isSellerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "9AF19A"))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .frame(height: 64)
    }

    // MARK: - Messages List

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isMine: isMyMessage(message)
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let last = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let last = viewModel.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Message Input

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField(String(localized: "chats_message_placeholder"), text: $viewModel.messageText, axis: .vertical)
                .font(.onest(.regular, size: 16))
                .lineLimit(1...5)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "F2F2F2"))
                .cornerRadius(24)

            Button(action: {
                Task { await viewModel.sendMessage() }
            }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 48, height: 48)
                    .background(
                        viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color(hex: "F2F2F2")
                        : Color(hex: "9AF19A")
                    )
                    .clipShape(Circle())
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSending)
            .animation(.easeInOut(duration: 0.15), value: viewModel.messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Helpers

    private func isMyMessage(_ message: Message) -> Bool {
        guard let currentUserId = SupabaseService.shared.client.auth.currentUser?.id else { return false }
        return message.senderId == currentUserId
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: Message
    let isMine: Bool

    var body: some View {
        HStack {
            if isMine { Spacer(minLength: 60) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .font(.onest(.regular, size: 15))
                        .foregroundColor(isMine ? .black : .black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isMine ? Color(hex: "B8EEA6") : Color.white)
                        .cornerRadius(18, corners: isMine
                            ? [.topLeft, .topRight, .bottomLeft]
                            : [.topLeft, .topRight, .bottomRight])
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                }

                Text(message.createdAt.formatted(.dateTime.hour().minute()))
                    .font(.onest(.regular, size: 11))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }

            if !isMine { Spacer(minLength: 60) }
        }
    }
}

// MARK: - RoundedCorner on specific corners helper

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(SpecificRoundedCorner(radius: radius, corners: corners))
    }
}

private struct SpecificRoundedCorner: Shape {
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
