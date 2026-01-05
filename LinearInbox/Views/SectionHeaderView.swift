import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let count: Int
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: { isExpanded.toggle() }) {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 12)

                Text(title)
                    .font(.system(.headline))
                    .foregroundColor(.primary)

                Text("\(count)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)

                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        SectionHeaderView(title: "In Progress", count: 3, isExpanded: .constant(true))
        SectionHeaderView(title: "Todo", count: 5, isExpanded: .constant(false))
    }
    .frame(width: 300)
    .padding()
}
