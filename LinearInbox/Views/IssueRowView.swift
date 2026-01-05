import SwiftUI

struct IssueRowView: View {
    let issue: Issue
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Priority indicator
                Circle()
                    .fill(priorityColor.opacity(0.9))
                    .frame(width: 8, height: 8)

                // Issue identifier
                Text(issue.identifier)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)

                // Issue title
                Text(issue.title)
                    .font(.system(.body))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var priorityColor: Color {
        switch issue.priority {
        case 1: return .red          // Urgent
        case 2: return .orange       // High
        case 3: return .yellow       // Medium
        case 4: return .blue         // Low
        default: return .gray        // No priority
        }
    }
}

#Preview {
    VStack {
        IssueRowView(
            issue: Issue(
                id: "1",
                identifier: "ENG-123",
                title: "Fix critical bug in authentication",
                priority: 1,
                priorityLabel: "Urgent",
                url: "https://linear.app",
                state: WorkflowState(id: "1", name: "In Progress", type: "started")
            ),
            onTap: {}
        )
        IssueRowView(
            issue: Issue(
                id: "2",
                identifier: "ENG-456",
                title: "Add new feature for user dashboard with very long title that should truncate",
                priority: 3,
                priorityLabel: "Medium",
                url: "https://linear.app",
                state: WorkflowState(id: "2", name: "Todo", type: "unstarted")
            ),
            onTap: {}
        )
    }
    .frame(width: 350)
    .padding()
}
