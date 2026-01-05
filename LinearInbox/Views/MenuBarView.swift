import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = IssuesViewModel()

    @State private var readyToMergeExpanded = true
    @State private var inReviewExpanded = true
    @State private var inProgressExpanded = true
    @State private var todoExpanded = true
    @State private var backlogExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showSettings || !viewModel.hasAPIKey {
                SettingsView(viewModel: viewModel)
            } else {
                issuesContent
            }
        }
        .frame(width: 380, height: 500)
        .task {
            await viewModel.refresh()
        }
    }

    // MARK: - Issues Content

    private var issuesContent: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            // Error Banner
            if let error = viewModel.error {
                errorBanner(error)
            }

            // Issues List
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    // Ready to Merge Section
                    if !viewModel.readyToMergeIssues.isEmpty {
                        issueSection(
                            title: "Ready to Merge",
                            issues: viewModel.readyToMergeIssues,
                            isExpanded: $readyToMergeExpanded
                        )
                    }

                    // In Review Section
                    if !viewModel.inReviewIssues.isEmpty {
                        issueSection(
                            title: "In Review",
                            issues: viewModel.inReviewIssues,
                            isExpanded: $inReviewExpanded
                        )
                    }

                    // In Progress Section
                    if !viewModel.inProgressIssues.isEmpty {
                        issueSection(
                            title: "In Progress",
                            issues: viewModel.inProgressIssues,
                            isExpanded: $inProgressExpanded
                        )
                    }

                    // Todo Section
                    if !viewModel.todoIssues.isEmpty {
                        issueSection(
                            title: "Todo",
                            issues: viewModel.todoIssues,
                            isExpanded: $todoExpanded
                        )
                    }

                    // Backlog Section
                    if !viewModel.backlogIssues.isEmpty {
                        issueSection(
                            title: "Backlog",
                            issues: viewModel.backlogIssues,
                            isExpanded: $backlogExpanded
                        )
                    }

                    // Empty State
                    if viewModel.totalIssueCount == 0 && !viewModel.isLoading {
                        emptyState
                    }
                }
                .padding(.bottom, 8)
            }

            Divider()

            // Footer
            footerView
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Linear Inbox")
                    .font(.headline)

                Text("Updated \(viewModel.lastUpdatedText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                Task { await viewModel.refresh() }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
        }
    }

    // MARK: - Issue Section

    private func issueSection(title: String, issues: [Issue], isExpanded: Binding<Bool>) -> some View {
        Section {
            if isExpanded.wrappedValue {
                ForEach(issues) { issue in
                    IssueRowView(issue: issue) {
                        viewModel.openIssue(issue)
                    }
                }
            }
        } header: {
            SectionHeaderView(
                title: title,
                count: issues.count,
                isExpanded: isExpanded
            )
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text(message)
                .font(.caption)
                .lineLimit(2)

            Spacer()

            Button("Retry") {
                Task { await viewModel.refresh() }
            }
            .font(.caption)
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.green)

            Text("All clear!")
                .font(.headline)

            Text("No issues assigned to you")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Text("\(viewModel.totalIssueCount) issues")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: { viewModel.showSettings = true }) {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MenuBarView()
}
