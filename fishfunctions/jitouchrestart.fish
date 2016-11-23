function jitouchrestart --description 'restart jitouch'
  open /Library/PreferencePanes/Jitouch.prefPane/
  sleep 2
  killall 'System Preferences'
end
