cask 'linearinbox' do
  version '1.0'
  sha256 'PENDING_FIRST_RELEASE'

  url "https://github.com/ZainW/LinearInbox/releases/download/v#{version}/LinearInbox-#{version}.dmg"
  name 'LinearInbox'
  desc 'Menu bar app for Linear issues'
  homepage 'https://github.com/ZainW/LinearInbox'

  depends_on macos: '>= :ventura'

  app 'LinearInbox.app'

  zap trash: [
    '~/Library/Preferences/com.zain.LinearInbox.plist',
    '~/Library/Application Support/com.zain.LinearInbox'
  ]

  caveats <<~EOS
    LinearInbox is an unsigned app. On first launch:
    1. Right-click the app and select "Open"
    2. Click "Open" in the dialog that appears

    Or allow it in System Settings > Privacy & Security.
  EOS
end
