import SwiftUI

struct FeedAddressPickerSheet: View {
    @Binding var isPresented: Bool
    var onAddNew: () -> Void = {}
    var onDetectLocation: () -> Void = {}

    private var currentAddress: String {
        UserDefaults.standard.string(forKey: "userAddress") ?? "Адреса не вказана"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header
            HStack(alignment: .center) {
                Text("Поточна адреса")
                    .font(.onest(.bold, size: 18))
                    .foregroundColor(.black)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "F2F2F2"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)

            // MARK: - Current Address Row
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "9AF19A"))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Адреса доставки")
                        .font(.onest(.regular, size: 12))
                        .foregroundColor(.gray)
                    Text(currentAddress)
                        .font(.onest(.medium, size: 15))
                        .foregroundColor(.black)
                        .lineLimit(2)
                }

                Spacer()

                Button {
                    isPresented = false
                    onAddNew()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(hex: "F7F7F7"))
            .cornerRadius(16)
            .padding(.horizontal, 20)

            Spacer().frame(height: 24)

            // MARK: - Add New Address
            Button {
                isPresented = false
                onAddNew()
            } label: {
                Text("Додати нову адресу")
                    .font(.onest(.semiBold, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "B8EEA6"))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 12)

            // MARK: - Detect Location
            Button {
                isPresented = false
                onDetectLocation()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                    Text("Визначити місцезнаходження")
                        .font(.onest(.medium, size: 16))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.white)
    }
}
