import SwiftUI

enum ContentTab: String, CaseIterable {
    case myIssues = "My Issues"
    case projects = "Projects"
    case favorites = "Favorites"
}

struct MenuBarView: View {
    @StateObject private var viewModel = IssuesViewModel()

    @AppStorage("selectedTab") private var selectedTab: String = ContentTab.myIssues.rawValue

    @State private var readyToMergeExpanded = true
    @State private var inReviewExpanded = true
    @State private var inProgressExpanded = true
    @State private var todoExpanded = true
    @State private var backlogExpanded = false

    // Project view state
    @State private var projectReadyToMergeExpanded = true
    @State private var projectInReviewExpanded = true
    @State private var projectInProgressExpanded = true
    @State private var projectTodoExpanded = true
    @State private var projectBacklogExpanded = false

    private var currentTab: ContentTab {
        ContentTab(rawValue: selectedTab) ?? .myIssues
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.showSettings || !viewModel.hasAPIKey {
                SettingsView(viewModel: viewModel)
            } else if viewModel.selectedProject != nil {
                projectIssuesContent
            } else {
                mainContent
            }
        }
        .frame(width: 380, height: 500)
        .task {
            await viewModel.refresh()
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
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

            // Tab Picker
            tabPicker
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            // Content based on selected tab
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    switch currentTab {
                    case .myIssues:
                        issuesSections
                    case .projects:
                        projectsList
                    case .favorites:
                        favoritesList
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

    // MARK: - Tab Picker

    private var tabPicker: some View {
        Picker("View", selection: $selectedTab) {
            ForEach(ContentTab.allCases, id: \.rawValue) { tab in
                Text(tab.rawValue).tag(tab.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Project Issues Content

    private var projectIssuesContent: some View {
        VStack(spacing: 0) {
            // Header with back button
            projectHeaderView
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            Divider()

            // Error Banner
            if let error = viewModel.error {
                errorBanner(error)
            }

            // Project Issues
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if !viewModel.projectReadyToMergeIssues.isEmpty {
                        issueSection(
                            title: "Ready to Merge",
                            issues: viewModel.projectReadyToMergeIssues,
                            isExpanded: $projectReadyToMergeExpanded
                        )
                    }

                    if !viewModel.projectInReviewIssues.isEmpty {
                        issueSection(
                            title: "In Review",
                            issues: viewModel.projectInReviewIssues,
                            isExpanded: $projectInReviewExpanded
                        )
                    }

                    if !viewModel.projectInProgressIssues.isEmpty {
                        issueSection(
                            title: "In Progress",
                            issues: viewModel.projectInProgressIssues,
                            isExpanded: $projectInProgressExpanded
                        )
                    }

                    if !viewModel.projectTodoIssues.isEmpty {
                        issueSection(
                            title: "Todo",
                            issues: viewModel.projectTodoIssues,
                            isExpanded: $projectTodoExpanded
                        )
                    }

                    if !viewModel.projectBacklogIssues.isEmpty {
                        issueSection(
                            title: "Backlog",
                            issues: viewModel.projectBacklogIssues,
                            isExpanded: $projectBacklogExpanded
                        )
                    }

                    if viewModel.projectTotalIssueCount == 0 && !viewModel.isLoading {
                        projectEmptyState
                    }
                }
                .padding(.bottom, 8)
            }

            Divider()

            // Footer
            HStack {
                Text("\(viewModel.projectTotalIssueCount) issues")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
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

            Button(action: { viewModel.openCompose() }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .help("Create new issue")

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

    private var projectHeaderView: some View {
        HStack {
            Button(action: {
                Task { await viewModel.selectProject(nil) }
            }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.selectedProject?.name ?? "Project")
                    .font(.headline)
                    .lineLimit(1)

                Text("All issues")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { viewModel.openCompose() }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .help("Create new issue")

            Button(action: {
                if let project = viewModel.selectedProject {
                    Task { await viewModel.selectProject(project) }
                }
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

    // MARK: - Favorites List

    private var favoritesList: some View {
        Group {
            if viewModel.favorites.isEmpty && !viewModel.isLoading {
                VStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("No favorites")
                        .font(.headline)

                    Text("Star items in Linear to see them here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.favorites) { favorite in
                    FavoriteRowView(favorite: favorite) {
                        viewModel.openFavorite(favorite)
                    }
                }
            }
        }
    }

    // MARK: - Projects List

    private var projectsList: some View {
        Group {
            if viewModel.projects.isEmpty && !viewModel.isLoading {
                VStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("No projects")
                        .font(.headline)

                    Text("You don't have access to any projects")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.projects) { project in
                    ProjectRowView(project: project) {
                        Task { await viewModel.selectProject(project) }
                    }
                }
            }
        }
    }

    // MARK: - Issues Sections

    private var issuesSections: some View {
        Group {
            if !viewModel.readyToMergeIssues.isEmpty {
                issueSection(
                    title: "Ready to Merge",
                    issues: viewModel.readyToMergeIssues,
                    isExpanded: $readyToMergeExpanded
                )
            }

            if !viewModel.inReviewIssues.isEmpty {
                issueSection(
                    title: "In Review",
                    issues: viewModel.inReviewIssues,
                    isExpanded: $inReviewExpanded
                )
            }

            if !viewModel.inProgressIssues.isEmpty {
                issueSection(
                    title: "In Progress",
                    issues: viewModel.inProgressIssues,
                    isExpanded: $inProgressExpanded
                )
            }

            if !viewModel.todoIssues.isEmpty {
                issueSection(
                    title: "Todo",
                    issues: viewModel.todoIssues,
                    isExpanded: $todoExpanded
                )
            }

            if !viewModel.backlogIssues.isEmpty {
                issueSection(
                    title: "Backlog",
                    issues: viewModel.backlogIssues,
                    isExpanded: $backlogExpanded
                )
            }

            if viewModel.totalIssueCount == 0 && !viewModel.isLoading {
                emptyState
            }
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

    private var projectEmptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No issues")
                .font(.headline)

            Text("This project has no active issues")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Group {
                switch currentTab {
                case .myIssues:
                    Text("\(viewModel.totalIssueCount) issues")
                case .projects:
                    Text("\(viewModel.projects.count) projects")
                case .favorites:
                    Text("\(viewModel.favorites.count) favorites")
                }
            }
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

// MARK: - Favorite Row View

struct FavoriteRowView: View {
    let favorite: Favorite
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: favorite.iconName)
                    .foregroundColor(favorite.url != nil ? .accentColor : .secondary)
                    .frame(width: 16)

                Text(favorite.name)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                if favorite.url != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(favorite.url == nil)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Project Row View

struct ProjectRowView: View {
    let project: Project
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "folder")
                    .foregroundColor(.accentColor)
                    .frame(width: 16)

                Text(project.name)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    MenuBarView()
}
