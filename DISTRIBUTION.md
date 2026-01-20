# Distribution Guide

LinearInbox is distributed as an unsigned DMG via GitHub Releases and Homebrew.

## Automated Releases (GitHub Actions)

Releases are fully automated. To create a new release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The GitHub Action will:
1. Build the app (unsigned, Release configuration)
2. Create a DMG
3. Create a GitHub Release with the DMG attached
4. Automatically update the Homebrew tap with the new version and SHA256

### One-Time Setup

Before the first release, you need to:

1. **Push this repo to GitHub** as `ZainW/LinearInbox`

2. **Create the Homebrew tap repo:**
   ```bash
   # Create a new repo on GitHub named: homebrew-linearinbox
   # Then push the tap contents:
   cd homebrew-tap
   git init
   git add .
   git commit -m "Initial tap setup"
   git remote add origin https://github.com/ZainW/homebrew-linearinbox.git
   git push -u origin main
   ```

3. **Create a Personal Access Token (PAT):**
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
   - Create a token with:
     - Repository access: `ZainW/homebrew-linearinbox`
     - Permissions: Contents (Read and write)
   - Copy the token

4. **Add the token as a repository secret:**
   - Go to `ZainW/LinearInbox` → Settings → Secrets and variables → Actions
   - Create a new secret named `TAP_GITHUB_TOKEN`
   - Paste the PAT

## Manual Release (Optional)

If you prefer to release manually:

```bash
./scripts/build-dmg.sh
```

This builds the app and creates `dist/LinearInbox-<version>.dmg`.

## Installation

### Via Homebrew (Recommended)

```bash
brew tap ZainW/linearinbox
brew install --cask linearinbox
```

Update with:
```bash
brew upgrade --cask linearinbox
```

### Manual Installation

1. Download the DMG from [GitHub Releases](https://github.com/ZainW/LinearInbox/releases)
2. Open the DMG and drag LinearInbox to Applications
3. First launch: Right-click → Open (required for unsigned apps)

## Launch at Login

The app includes a "Launch at login" toggle in Settings. This uses macOS's `SMAppService` and works without code signing.

## Notes for Unsigned Apps

- Gatekeeper will show a warning on first launch
- Right-click → Open, or allow in System Settings → Privacy & Security
- This is expected for apps distributed outside the App Store
