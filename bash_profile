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

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
