import Foundation

enum LinearAPIError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case graphQLError(String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured"
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .graphQLError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}

final class LinearAPIService {
    static let shared = LinearAPIService()

    private let endpoint = URL(string: "https://api.linear.app/graphql")!
    private let session = URLSession.shared
    private let keychain = KeychainService.shared

    private init() {}

    // MARK: - Fetch Assigned Issues

    func fetchAssignedIssues() async throws -> [Issue] {
        guard let apiKey = try? keychain.getAPIKey() else {
            throw LinearAPIError.noAPIKey
        }

        let query = """
        query MyIssues {
          viewer {
            assignedIssues {
              nodes {
                id
                identifier
                title
                priority
                priorityLabel
                url
                state {
                  id
                  name
                  type
                }
              }
            }
          }
        }
        """

        let body: [String: Any] = ["query": query]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LinearAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw LinearAPIError.graphQLError("Invalid API key")
            }
            throw LinearAPIError.graphQLError("HTTP \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        let graphQLResponse: GraphQLResponse<ViewerResponse>

        do {
            graphQLResponse = try decoder.decode(GraphQLResponse<ViewerResponse>.self, from: data)
        } catch {
            throw LinearAPIError.decodingError(error)
        }

        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw LinearAPIError.graphQLError(errors.map(\.message).joined(separator: ", "))
        }

        guard let viewerResponse = graphQLResponse.data else {
            throw LinearAPIError.invalidResponse
        }

        return viewerResponse.viewer.assignedIssues.nodes
    }

    // MARK: - Fetch Favorites

    func fetchFavorites() async throws -> [Favorite] {
        guard let apiKey = try? keychain.getAPIKey() else {
            throw LinearAPIError.noAPIKey
        }

        let query = """
        query MyFavorites {
          favorites {
            nodes {
              id
              type
              predefinedViewType
              issue {
                id
                identifier
                title
                url
              }
              project {
                id
                name
                icon
                color
              }
              customView {
                id
                name
                icon
                color
              }
              cycle {
                id
                name
              }
              label {
                id
                name
                color
              }
            }
          }
        }
        """

        let body: [String: Any] = ["query": query]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LinearAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw LinearAPIError.graphQLError("Invalid API key")
            }
            throw LinearAPIError.graphQLError("HTTP \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        let graphQLResponse: GraphQLResponse<FavoritesResponse>

        do {
            graphQLResponse = try decoder.decode(GraphQLResponse<FavoritesResponse>.self, from: data)
        } catch {
            throw LinearAPIError.decodingError(error)
        }

        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw LinearAPIError.graphQLError(errors.map(\.message).joined(separator: ", "))
        }

        guard let favoritesResponse = graphQLResponse.data else {
            throw LinearAPIError.invalidResponse
        }

        return favoritesResponse.favorites.nodes.compactMap { $0.toFavorite() }
    }

    // MARK: - Fetch Projects

    func fetchProjects() async throws -> [Project] {
        guard let apiKey = try? keychain.getAPIKey() else {
            throw LinearAPIError.noAPIKey
        }

        let query = """
        query MyProjects {
          projects {
            nodes {
              id
              name
              icon
              color
            }
          }
        }
        """

        let body: [String: Any] = ["query": query]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LinearAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw LinearAPIError.graphQLError("Invalid API key")
            }
            throw LinearAPIError.graphQLError("HTTP \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        let graphQLResponse: GraphQLResponse<ProjectsResponse>

        do {
            graphQLResponse = try decoder.decode(GraphQLResponse<ProjectsResponse>.self, from: data)
        } catch {
            throw LinearAPIError.decodingError(error)
        }

        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw LinearAPIError.graphQLError(errors.map(\.message).joined(separator: ", "))
        }

        guard let projectsResponse = graphQLResponse.data else {
            throw LinearAPIError.invalidResponse
        }

        return projectsResponse.projects.nodes
    }

    // MARK: - Fetch Project Issues

    func fetchProjectIssues(projectId: String) async throws -> [Issue] {
        guard let apiKey = try? keychain.getAPIKey() else {
            throw LinearAPIError.noAPIKey
        }

        let query = """
        query ProjectIssues($projectId: String!) {
          project(id: $projectId) {
            issues {
              nodes {
                id
                identifier
                title
                priority
                priorityLabel
                url
                state {
                  id
                  name
                  type
                }
              }
            }
          }
        }
        """

        let body: [String: Any] = [
            "query": query,
            "variables": ["projectId": projectId]
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LinearAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw LinearAPIError.graphQLError("Invalid API key")
            }
            throw LinearAPIError.graphQLError("HTTP \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        let graphQLResponse: GraphQLResponse<ProjectIssuesResponse>

        do {
            graphQLResponse = try decoder.decode(GraphQLResponse<ProjectIssuesResponse>.self, from: data)
        } catch {
            throw LinearAPIError.decodingError(error)
        }

        if let errors = graphQLResponse.errors, !errors.isEmpty {
            throw LinearAPIError.graphQLError(errors.map(\.message).joined(separator: ", "))
        }

        guard let projectResponse = graphQLResponse.data else {
            throw LinearAPIError.invalidResponse
        }

        return projectResponse.project.issues.nodes
    }
}
