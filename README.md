# @MrLoh Mac Config

This Repo contains my system wide configuration files and scripts. It is based on the setup
suggested in [this article][1].

### Usage

1. Install [iTerm2](https://iterm2.com)
2. Install [Homebrew](https://brew.sh)
3. Create a Repos folder
	- `mkdir ~/Repos && cd ~/Repos`
4. install git and clone this repo: 
	- `brew install git`
	- `git clone https://github.com/MrLoh/configs.git`
5. Install [Operator Mono Lig](https://github.com/kiliman/operator-mono-lig) fonts
6. Load iTerm preferences from `~/Repos/_config/`
	![iTerm Preferences > General > Preferences](./ressources/iterm_load_prefs.png)
7. Install and configure [Fish Shell](https://fishshell.com)
	- `./fishsetup.sh`
8. Create symlinks for profiles (!This will overwrite existing profiles)
	- `./link.sh`

Since the configurations are now symlinked, any further changes can easily be committed to git and
changes from other machines can easily be pulled down via git.


### Content

This contains the following configs:
- gitconfig
- global gitignore
- bashrc
- zshrc
- fishconfig
- fishfunctions

This helps setup the following tools:
- iTerm
- Homebrew
- Git and Hub
- Fish Shell
- NVM for Fish

[1]: https://www.digitalocean.com/community/tutorials/how-to-use-git-to-manage-your-user-configuration-files-on-a-linux-vps#creating-a-configuration-directory-to-store-files