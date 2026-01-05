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
