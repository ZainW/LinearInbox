# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

Build and run from Xcode:
- Open `LinearInbox.xcodeproj` in Xcode
- Build: ⌘B
- Run: ⌘R

Build from command line:
```bash
xcodebuild -project LinearInbox.xcodeproj -scheme LinearInbox -configuration Debug build
```

## Architecture

LinearInbox is a native macOS menu bar app that displays Linear issues assigned to the current user. It runs as a menu bar extra (no dock icon) using SwiftUI's `MenuBarExtra`.

### Key Components

**App Entry Point** (`LinearInboxApp.swift`): Uses `MenuBarExtra` with `.window` style to create a popover menu bar app.

**MVVM Pattern**:
- `IssuesViewModel`: Central state manager using `@MainActor`. Handles issue fetching, grouping by state type (In Progress/Todo/Backlog), sorting by priority, and auto-refresh timer management.
- Views observe the ViewModel via `@StateObject`/`@ObservedObject`.

**Services**:
- `LinearAPIService`: Singleton GraphQL client for Linear API (`https://api.linear.app/graphql`). Fetches issues assigned to the authenticated user.
- `KeychainService`: Singleton wrapper around Security framework for secure API key storage using `kSecClassGenericPassword`.

**Data Flow**:
1. User enters API key → stored in Keychain
2. ViewModel fetches issues via `LinearAPIService.fetchAssignedIssues()`
3. Issues grouped by `WorkflowState.type` (started/unstarted/backlog) and sorted by priority
4. Views render grouped issues with collapsible sections

### State Types
Issues are categorized by Linear's workflow state type:
- `started` → "In Progress"
- `unstarted` → "Todo"
- `backlog` → "Backlog"
- Other states (completed, canceled) are filtered out

### Priority Sorting
Within each section, issues sort by priority (1=Urgent, 2=High, 3=Medium, 4=Low). Priority 0 (none) sorts last.

## Configuration

- **API Key**: Stored in Keychain under service `com.linearinbox.apikey`
- **Auto-refresh**: Uses `@AppStorage("autoRefreshInterval")` with values: 0 (off), 60, 300, 900, 1800 seconds
- **LSUIElement**: Set to YES in Info.plist to hide dock icon
- **App Sandbox**: Enabled with outgoing network connections

## External Dependencies

None - uses only Apple frameworks (SwiftUI, Foundation, Security).
