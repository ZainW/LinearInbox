import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: IssuesViewModel
    @State private var apiKey = ""
    @State private var errorMessage: String?
    @State private var showingClearConfirmation = false

    @AppStorage("autoRefreshInterval") private var autoRefreshInterval: Double = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button(action: { viewModel.showSettings = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // API Key Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Linear API Key")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if viewModel.hasAPIKey {
                    HStack {
                        Text("••••••••••••••••")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Clear") {
                            showingClearConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("lin_api_...", text: $apiKey)
                            .textFieldStyle(.roundedBorder)

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        Button("Save API Key") {
                            saveAPIKey()
                        }
                        .disabled(apiKey.isEmpty)
                    }
                }

                Text("Get your API key from Linear Settings → Account → API")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Auto-refresh Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Auto-refresh")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Picker("Interval", selection: $autoRefreshInterval) {
                    Text("Off").tag(0.0)
                    Text("1 minute").tag(60.0)
                    Text("5 minutes").tag(300.0)
                    Text("15 minutes").tag(900.0)
                    Text("30 minutes").tag(1800.0)
                }
                .pickerStyle(.menu)
                .onChange(of: autoRefreshInterval) { _, newValue in
                    viewModel.updateAutoRefreshInterval(newValue)
                }
            }

            Divider()

            // Quit Button
            Button("Quit Linear Inbox") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)

            Spacer()
        }
        .padding()
        .frame(width: 300)
        .alert("Clear API Key?", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearAPIKey()
            }
        } message: {
            Text("You'll need to enter a new API key to continue using the app.")
        }
    }

    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }

        do {
            try viewModel.saveAPIKey(apiKey)
            apiKey = ""
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save API key"
        }
    }

    private func clearAPIKey() {
        do {
            try viewModel.clearAPIKey()
        } catch {
            errorMessage = "Failed to clear API key"
        }
    }
}

#Preview {
    SettingsView(viewModel: IssuesViewModel())
}
