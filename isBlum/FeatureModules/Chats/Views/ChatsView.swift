import SwiftUI

struct ChatsView: View {
    @StateObject private var viewModel = ChatsViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "chats_nav_title",
                showBackButton: false
            )

            if viewModel.isShowingCachedData {
                offlineBanner
            }

            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)

                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.chats.isEmpty {
                    emptyStateView
                } else {
                    chatsList
                }
            }
        }
        .background(Color(hex: "#B8EEA6").opacity(0.2))
        .task {
            guard authViewModel.isAuthenticated else { return }
            await viewModel.fetchChats()
            viewModel.subscribeToUpdates()
        }
        .onAppear {
            guard authViewModel.isAuthenticated else { return }
            Task { await viewModel.fetchChats() }
        }
        .onDisappear {
            viewModel.unsubscribe()
        }
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13, weight: .medium))
            Text("offline_cached_data")
                .font(.onest(.medium, size: 13))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.8))
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Image(.feather)
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .foregroundColor(.black)
                .padding(.bottom, 32)

            Text("chats_empty_title")
                .font(.onest(.bold, size: 24))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text("chats_empty_description")
                .font(.onest(.regular, size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { coordinator.selectedTab = .feed }) {
                Text("chats_empty_button")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#B8EEA6"))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Chats List

    private var chatsList: some View {
        List {
            ForEach(viewModel.chats) { chat in
                ChatRowView(chat: chat)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparatorTint(Color(hex: "F2F2F2"))
                    .listRowBackground(Color.white)
                    .onTapGesture {
                        Task {
                            if chat.isVirtual, let orderId = chat.orderId {
                                if let realChat = await ChatsViewModel.findOrCreateChat(
                                    orderId: orderId,
                                    sellerId: chat.sellerId
                                ) {
                                    coordinator.showChatRoom(realChat)
                                }
                            } else {
                                coordinator.showChatRoom(chat)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteChat(chat) }
                        } label: {
                            Label("chats_delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.top, 8)
    }
}

#Preview {
    ChatsView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
