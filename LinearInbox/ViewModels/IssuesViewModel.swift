import Foundation
import SwiftUI
import Combine

@MainActor
final class IssuesViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var readyToMergeIssues: [Issue] = []
    @Published private(set) var inReviewIssues: [Issue] = []
    @Published private(set) var inProgressIssues: [Issue] = []
    @Published private(set) var todoIssues: [Issue] = []
    @Published private(set) var backlogIssues: [Issue] = []

    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var lastUpdated: Date?

    @Published var showSettings = false

    // MARK: - Private Properties

    private let apiService = LinearAPIService.shared
    private let keychain = KeychainService.shared
    private var refreshTimer: Timer?

    @AppStorage("autoRefreshInterval") private var autoRefreshInterval: Double = 300 // 5 minutes

    // MARK: - Computed Properties

    var hasAPIKey: Bool {
        keychain.hasAPIKey
    }

    var totalIssueCount: Int {
        readyToMergeIssues.count + inReviewIssues.count + inProgressIssues.count + todoIssues.count + backlogIssues.count
    }

    var lastUpdatedText: String {
        guard let lastUpdated else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }

    // MARK: - Initialization

    init() {
        setupAutoRefresh()
    }

    // MARK: - Public Methods

    func refresh() async {
        guard hasAPIKey else {
            showSettings = true
            return
        }

        isLoading = true
        error = nil

        do {
            let issues = try await apiService.fetchAssignedIssues()
            groupAndSortIssues(issues)
            lastUpdated = Date()
        } catch let apiError as LinearAPIError {
            error = apiError.errorDescription
            if case .noAPIKey = apiError {
                showSettings = true
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func saveAPIKey(_ key: String) throws {
        try keychain.saveAPIKey(key)
        showSettings = false
        Task {
            await refresh()
        }
    }

    func clearAPIKey() throws {
        try keychain.deleteAPIKey()
        readyToMergeIssues = []
        inReviewIssues = []
        inProgressIssues = []
        todoIssues = []
        backlogIssues = []
        lastUpdated = nil
        showSettings = true
    }

    func openIssue(_ issue: Issue) {
        // Validate URL is from Linear before opening
        guard let originalURL = URL(string: issue.url),
              let host = originalURL.host,
              host == "linear.app" || host.hasSuffix(".linear.app") else {
            return
        }

        // Convert web URL to Linear desktop app URL
        // https://linear.app/team/issue/ENG-123 -> linear://team/issue/ENG-123
        let desktopURL = issue.url.replacingOccurrences(of: "https://linear.app/", with: "linear://")

        if let url = URL(string: desktopURL) {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Private Methods

    private func groupAndSortIssues(_ issues: [Issue]) {
        // Group by state type and name
        var readyToMerge: [Issue] = []
        var inReview: [Issue] = []
        var inProgress: [Issue] = []
        var todo: [Issue] = []
        var backlog: [Issue] = []

        for issue in issues {
            let stateType = issue.state.stateType

            switch stateType {
            case .started:
                // Further categorize by state name
                switch issue.state.name {
                case "Ready to Merge":
                    readyToMerge.append(issue)
                case "In Review":
                    inReview.append(issue)
                default:
                    inProgress.append(issue)
                }
            case .unstarted:
                todo.append(issue)
            case .backlog:
                backlog.append(issue)
            case nil:
                // Skip completed, canceled, or other unknown states
                continue
            }
        }

        // Sort each group by priority (lower number = higher priority)
        // Priority 0 (no priority) should come last
        let sortByPriority: (Issue, Issue) -> Bool = { a, b in
            if a.priority == 0 { return false }
            if b.priority == 0 { return true }
            return a.priority < b.priority
        }

        readyToMergeIssues = readyToMerge.sorted(by: sortByPriority)
        inReviewIssues = inReview.sorted(by: sortByPriority)
        inProgressIssues = inProgress.sorted(by: sortByPriority)
        todoIssues = todo.sorted(by: sortByPriority)
        backlogIssues = backlog.sorted(by: sortByPriority)
    }

    private func setupAutoRefresh() {
        refreshTimer?.invalidate()

        guard autoRefreshInterval > 0 else { return }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refresh()
            }
        }
    }

    func updateAutoRefreshInterval(_ interval: Double) {
        autoRefreshInterval = interval
        setupAutoRefresh()
    }
}
