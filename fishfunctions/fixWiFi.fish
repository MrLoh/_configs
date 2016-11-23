function fixWiFi --description 'restart launchtl to fix internet in safari'
  sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.discoveryd.plist
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.discoveryd.plist
end
