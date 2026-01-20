cask 'linearinbox' do
  version '1.0'
  sha256 'fed9c2e126c21c7c270e6c4011b2c42ac599ebdec4ab9b10213a3a72238b64ea'

  url "https://github.com/ZainW/LinearInbox/releases/download/v#{version}/LinearInbox-#{version}.dmg"
  name 'LinearInbox'
  desc 'Menu bar app for Linear issues'
  homepage 'https://github.com/ZainW/LinearInbox'

  depends_on macos: '>= :ventura'

  app 'LinearInbox.app'

  postflight do
    system_command '/usr/bin/xattr',
                   args: ['-cr', "#{appdir}/LinearInbox.app"],
                   sudo: false
  end

  zap trash: [
    '~/Library/Preferences/com.zain.LinearInbox.plist',
    '~/Library/Application Support/com.zain.LinearInbox'
  ]
end
