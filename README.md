# Linear Inbox

A native macOS menu bar app that shows your Linear tickets organized by status.

## Features

- Shows tickets assigned to you from Linear
- Organized into sections: **In Progress**, **Todo**, **Backlog**
- Each section sorted by priority (Urgent → High → Medium → Low)
- Auto-refresh (configurable interval)
- Manual refresh button
- Click any ticket to open it in Linear
- Secure API key storage in macOS Keychain

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- A Linear account with a personal API key

## Setup

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose **macOS** → **App**
4. Configure:
   - Product Name: `LinearInbox`
   - Team: Your team
   - Organization Identifier: `com.yourname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Include Tests"
5. Save to `/Users/zain/labs/LinearInbox`

### 2. Replace Generated Files

After Xcode creates the project:

1. Delete the generated `ContentView.swift` and `LinearInboxApp.swift`
2. Drag all files from `LinearInbox/` folder into the Xcode project:
   - `LinearInboxApp.swift`
   - `Models/Issue.swift`
   - `Services/KeychainService.swift`
   - `Services/LinearAPIService.swift`
   - `ViewModels/IssuesViewModel.swift`
   - `Views/MenuBarView.swift`
   - `Views/IssueRowView.swift`
   - `Views/SectionHeaderView.swift`
   - `Views/SettingsView.swift`

### 3. Configure Project Settings

1. Select the project in the navigator
2. Select the **LinearInbox** target
3. **General** tab:
   - Deployment Target: **macOS 13.0**
4. **Signing & Capabilities** tab:
   - Add capability: **Keychain Sharing**
   - Keychain Group: `com.linearinbox.apikey`
   - Add capability: **App Sandbox**
   - Enable: **Outgoing Connections (Client)**
5. **Info** tab:
   - Add: `Application is agent (UIElement)` = `YES`
   - This hides the dock icon

### 4. Get Your Linear API Key

1. Go to [Linear](https://linear.app)
2. Click your avatar → Settings
3. Go to **Account** → **API**
4. Create a new personal API key
5. Copy the key (starts with `lin_api_`)

### 5. Run the App

1. Build and run (⌘R)
2. Look for the tray icon in the menu bar
3. Click it and enter your API key in Settings
4. Your tickets will load automatically

## Project Structure

```
LinearInbox/
├── LinearInboxApp.swift          # App entry point with MenuBarExtra
├── Models/
│   └── Issue.swift               # Data models
├── Services/
│   ├── KeychainService.swift     # Secure API key storage
│   └── LinearAPIService.swift    # GraphQL API client
├── ViewModels/
│   └── IssuesViewModel.swift     # State management
└── Views/
    ├── MenuBarView.swift         # Main popover
    ├── IssueRowView.swift        # Issue row
    ├── SectionHeaderView.swift   # Section headers
    └── SettingsView.swift        # Settings panel
```

## Configuration

- **Auto-refresh interval**: Configure in Settings (Off, 1min, 5min, 15min, 30min)
- **API Key**: Stored securely in macOS Keychain
