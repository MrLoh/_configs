#!/opt/homebrew/bin/fish
# Optional fish setup. Does not change the default shell — run ./setup.zsh.sh for that.
# Start fish anytime with: fish

# add homebrew to path
fish_add_path /opt/homebrew/bin

# add fish to known shells
sudo bash -c 'echo '(which fish)' >> /etc/shells'

# install oh my fish (https://github.com/oh-my-fish/oh-my-fish)
curl -L https://get.oh-my.fish | fish

# install bob the fish theme https://github.com/oh-my-fish/theme-bobthefish
omf install bobthefish

# setup iTerm fish shell integration (https://iterm2.com/documentation-shell-integration.html)
curl -L https://iterm2.com/shell_integration/fish -o ~/.iterm2_shell_integration.fish

# install cocoa pods 
sudo gem install cocoapods

# install xcode command line tools
xcode-select --install

# use Xcode app instead of just command line tools
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# start fish shell
fish