import SwiftUI

struct ChatRowView: View {
    let chat: Chat

    private var currentUserId: UUID? {
        SupabaseService.shared.client.auth.currentUser?.id
    }

    private var isLastMessageMine: Bool {
        guard let senderId = chat.lastSenderId,
              let userId = currentUserId else { return false }
        return senderId == userId
    }

    /// "Ви: 📷 Фото" / "Ви: текст" / "📷 Фото" / "текст" / ""
    private var lastMessagePreview: some View {
        Group {
            if chat.lastMessageIsImage {
                HStack(spacing: 3) {
                    if isLastMessageMine {
                        Text("Ви:")
                            .foregroundColor(.black.opacity(0.5))
                    }
                    Image(systemName: "camera")
                        .font(.system(size: 13))
                    Text("Фото")
                }
                .font(.onest(.regular, size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
            } else if let text = chat.lastMessage, !text.isEmpty {
                HStack(spacing: 3) {
                    if isLastMessageMine {
                        Text("Ви:")
                            .foregroundColor(.black.opacity(0.5))
                    }
                    Text(text)
                }
                .font(.onest(.regular, size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
            } else {
                Text("").font(.onest(.regular, size: 14))
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: chat.avatarColor))
                    .frame(width: 48, height: 48)

                Image(.chatVectorIcon)
                    .foregroundColor(Color(hex: chat.avatarIconColor))
            }

            // Name + last message
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(chat.sellerName)
                        .font(.onest(.semiBold, size: 16))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    if chat.isSellerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "9AF19A"))
                    }
                }

                lastMessagePreview
            }

            Spacer()

            // Time + unread badge
            VStack(alignment: .trailing, spacing: 6) {
                Text(chat.formattedTime)
                    .font(.onest(.regular, size: 13))
                    .foregroundColor(.gray)

                if chat.unreadCount > 0 {
                    Text("\(chat.unreadCount)")
                        .font(.onest(.regular, size: 12))
                        .foregroundColor(.black)
                        .frame(minWidth: 20, minHeight: 20)
                        .padding(.horizontal, 5)
                        .background(Color(hex: "9AF19A"))
                        .clipShape(Circle())
                } else {
                    Color.clear.frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
