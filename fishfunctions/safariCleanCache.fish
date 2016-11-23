function safariCleanCache --description 'Clean Safari Cash and restart'
  killall Safari
  rm ~/Library/Caches/com.apple.Safari/Cache.db*
  echo "deleted Safari Cache.db"
  sleep 1
  open /Applications/Safari.app
end
