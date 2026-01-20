# Agent Instructions

Instructions for AI agents working on this repository.

## Releasing a New Version

To release a new version of LinearInbox:

1. **Bump the version** in `LinearInbox.xcodeproj/project.pbxproj`:
   - Update `MARKETING_VERSION` (e.g., `1.0` → `1.1`)
   - Update `CURRENT_PROJECT_VERSION` if needed (build number)

2. **Commit the version bump**:
   ```bash
   git add -A
   git commit -m "Bump version to X.Y"
   ```

3. **Create and push a tag**:
   ```bash
   git tag vX.Y
   git push origin main
   git push origin vX.Y
   ```

The GitHub Action (`.github/workflows/release.yml`) will automatically:
- Build the app (unsigned, Release configuration)
- Create a DMG
- Publish a GitHub Release with the DMG attached
- Update the Homebrew tap (`ZainW/homebrew-linearinbox`) with the new version and SHA256

## Project Structure

```
LinearInbox/
├── LinearInboxApp.swift      # App entry point, MenuBarExtra
├── Models/
│   └── Issue.swift           # Linear issue data model
├── Views/
│   ├── MenuBarView.swift     # Main menu bar popover
│   ├── SettingsView.swift    # Settings panel
│   ├── IssueRowView.swift    # Individual issue row
│   └── SectionHeaderView.swift
├── ViewModels/
│   └── IssuesViewModel.swift # Central state manager
└── Services/
    ├── LinearAPIService.swift  # GraphQL client for Linear API
    ├── KeychainService.swift   # Secure API key storage
    └── LoginItemService.swift  # Launch at login (SMAppService)
```

## Key Files

- **Version**: `MARKETING_VERSION` in `LinearInbox.xcodeproj/project.pbxproj`
- **Bundle ID**: `com.zain.LinearInbox`
- **Entitlements**: `LinearInbox/LinearInbox.entitlements`
- **Build script**: `scripts/build-dmg.sh` (for local builds)
- **CI workflow**: `.github/workflows/release.yml`

## Homebrew

Users install via:
```bash
brew tap ZainW/linearinbox
brew install --cask linearinbox
```

The tap repo is at `github.com/ZainW/homebrew-linearinbox` and is auto-updated by the release workflow.
