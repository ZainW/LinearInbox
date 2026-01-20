import Foundation

// MARK: - State Type

enum StateType: String, Codable, CaseIterable {
    case started = "started"
    case unstarted = "unstarted"
    case backlog = "backlog"

    var displayName: String {
        switch self {
        case .started: return "In Progress"
        case .unstarted: return "Todo"
        case .backlog: return "Backlog"
        }
    }

    var sortOrder: Int {
        switch self {
        case .started: return 0
        case .unstarted: return 1
        case .backlog: return 2
        }
    }
}

// MARK: - Workflow State

struct WorkflowState: Codable, Equatable {
    let id: String
    let name: String
    let type: String

    var stateType: StateType? {
        StateType(rawValue: type)
    }
}

// MARK: - Issue

struct Issue: Identifiable, Codable, Equatable {
    let id: String
    let identifier: String
    let title: String
    let priority: Int
    let priorityLabel: String
    let url: String
    let state: WorkflowState

    var priorityColor: String {
        switch priority {
        case 1: return "urgent"    // Red
        case 2: return "high"      // Orange
        case 3: return "medium"    // Yellow
        case 4: return "low"       // Blue
        default: return "none"     // Gray
        }
    }
}

// MARK: - Favorite

struct Favorite: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let type: FavoriteType
    let icon: String?
    let color: String?
    let url: String?

    enum FavoriteType: String, Codable {
        case issue
        case project
        case customView
        case cycle
        case label
        case predefinedView = "predefinedViewType"
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = FavoriteType(rawValue: value) ?? .unknown
        }
    }

    var iconName: String {
        switch type {
        case .issue: return "doc.text"
        case .project: return "folder"
        case .customView, .predefinedView: return "line.3.horizontal.decrease.circle"
        case .cycle: return "arrow.triangle.2.circlepath"
        case .label: return "tag"
        case .unknown: return "star"
        }
    }
}

// MARK: - Project

struct Project: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let icon: String?
    let color: String?
}

// MARK: - GraphQL Response Types

struct GraphQLResponse<T: Codable>: Codable {
    let data: T?
    let errors: [GraphQLError]?
}

struct GraphQLError: Codable {
    let message: String
}

struct ViewerResponse: Codable {
    let viewer: Viewer
}

struct Viewer: Codable {
    let assignedIssues: IssueConnection
}

struct IssueConnection: Codable {
    let nodes: [Issue]
}

// MARK: - Favorites Response Types

struct FavoritesResponse: Codable {
    let favorites: FavoriteConnection
}

struct FavoriteConnection: Codable {
    let nodes: [FavoriteNode]
}

struct FavoriteNode: Codable {
    let id: String
    let type: String
    let issue: FavoriteIssue?
    let project: FavoriteProject?
    let customView: FavoriteCustomView?
    let cycle: FavoriteCycle?
    let label: FavoriteLabel?
    let predefinedViewType: String?

    func toFavorite() -> Favorite? {
        if let issue = issue {
            return Favorite(
                id: id,
                name: "\(issue.identifier): \(issue.title)",
                type: .issue,
                icon: nil,
                color: nil,
                url: issue.url
            )
        } else if let project = project {
            return Favorite(
                id: id,
                name: project.name,
                type: .project,
                icon: project.icon,
                color: project.color,
                url: "https://linear.app/project/\(project.id)"
            )
        } else if let customView = customView {
            return Favorite(
                id: id,
                name: customView.name,
                type: .customView,
                icon: customView.icon,
                color: customView.color,
                url: "https://linear.app/view/\(customView.id)"
            )
        } else if let cycle = cycle {
            return Favorite(
                id: id,
                name: cycle.name ?? "Cycle",
                type: .cycle,
                icon: nil,
                color: nil,
                url: nil
            )
        } else if let label = label {
            return Favorite(
                id: id,
                name: label.name,
                type: .label,
                icon: nil,
                color: label.color,
                url: nil
            )
        } else if let viewType = predefinedViewType {
            return Favorite(
                id: id,
                name: viewType.replacingOccurrences(of: "_", with: " ").capitalized,
                type: .predefinedView,
                icon: nil,
                color: nil,
                url: nil
            )
        }
        return nil
    }
}

struct FavoriteIssue: Codable {
    let id: String
    let identifier: String
    let title: String
    let url: String
}

struct FavoriteProject: Codable {
    let id: String
    let name: String
    let icon: String?
    let color: String?
}

struct FavoriteCustomView: Codable {
    let id: String
    let name: String
    let icon: String?
    let color: String?
}

struct FavoriteCycle: Codable {
    let id: String
    let name: String?
}

struct FavoriteLabel: Codable {
    let id: String
    let name: String
    let color: String
}

// MARK: - Projects Response Types

struct ProjectsResponse: Codable {
    let projects: ProjectConnection
}

struct ProjectConnection: Codable {
    let nodes: [Project]
}

// MARK: - Project Issues Response Types

struct ProjectIssuesResponse: Codable {
    let project: ProjectWithIssues
}

struct ProjectWithIssues: Codable {
    let issues: IssueConnection
}
