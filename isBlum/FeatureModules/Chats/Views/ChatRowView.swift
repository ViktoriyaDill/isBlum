import SwiftUI

struct ChatRowView: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: chat.avatarColor))
                    .frame(width: 48, height: 48)

                Text(chat.avatarLetter)
                    .font(.onest(.semiBold, size: 20))
                    .foregroundColor(.black.opacity(0.6))
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

                Text(chat.lastMessage ?? "")
                    .font(.onest(.regular, size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            // Time + unread badge
            VStack(alignment: .trailing, spacing: 6) {
                Text(chat.formattedTime)
                    .font(.onest(.regular, size: 13))
                    .foregroundColor(.gray)

                if chat.unreadCount > 0 {
                    Text("\(chat.unreadCount)")
                        .font(.onest(.bold, size: 12))
                        .foregroundColor(.black)
                        .frame(minWidth: 20, minHeight: 20)
                        .padding(.horizontal, 5)
                        .background(Color(hex: "9AF19A"))
                        .clipShape(Capsule())
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
