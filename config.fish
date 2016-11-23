# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# add node modules to path
set PATH ~/.npm-packages/bin $PATH

# Theme
set fish_theme robbyrussell

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-fish/plugins/*)
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
set fish_plugins git rails brew subl python node

# Path to your custom folder (default path is $FISH/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

# Enable rnev for fish
set -gx RBENV_ROOT /usr/local/var/rbenv
. (rbenv init -|psub)
test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# set dinghy environment variables for Docker
set -x DOCKER_HOST tcp://192.168.99.100:2376
set -x DOCKER_CERT_PATH /Users/tolo/.docker/machine/machines/dinghy
set -x DOCKER_MACHINE_NAME dinghy
set -x DOCKER_TLS_VERIFY 1

# disable .pyc files
set -x PYTHONDONTWRITEBYTECODE 1