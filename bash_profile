[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

export PATH=$PATH:/usr/local/sbin

# use micro as editor
export EDITOR=micro
export VISUAL="$EDITOR"

# setup postgres
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin

# add android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# use java 8
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# setup asdf
. $(brew --prefix asdf)/libexec/asdf.sh
export PATH=$PATH:$HOME/.asdf/shims