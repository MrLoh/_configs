# install fish and start fish
brew install fish
fish

# add homebrew to path
fish_add_path /opt/homebrew/bin

# add fish to known shells
sudo bash -c 'echo '(which fish)' >> /etc/shells'

# set default shell to fish
chsh -s (which fish)

# install oh my fish (https://github.com/oh-my-fish/oh-my-fish)
curl -L https://get.oh-my.fish | fish

# install fish function dependencies
brew install fzf
brew install hub

# install bob the fish theme https://github.com/oh-my-fish/theme-bobthefish
omf install bobthefish

# setup iTerm fish shell integration (https://iterm2.com/documentation-shell-integration.html)
curl -L https://iterm2.com/shell_integration/fish -o iterm2_shell_integration.fish