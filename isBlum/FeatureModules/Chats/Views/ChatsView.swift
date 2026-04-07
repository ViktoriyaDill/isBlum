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
        .onDisappear {
            viewModel.unsubscribe()
        }
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
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.chats) { chat in
                    ChatRowView(chat: chat)
                        .onTapGesture {
                            coordinator.chatsPath.append(AppRoute.chatRoom(chat: chat))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteChat(chat) }
                            } label: {
                                Label("chats_delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }

                    Divider()
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    ChatsView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
