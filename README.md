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
5. Create symlinks of profiles (!This will overwrite existing profiles)
	- `./link.sh`
6. Install [Operator Mono Lig](https://github.com/kiliman/operator-mono-lig) fonts
7. Load iTerm preferences from `~/Repos/_config/`
	![iTerm Preferences > General > Preferences](./ressources/iterm_load_prefs.png)

### Content

This contains the following configs:
- gitconfig
- global gitignore
- bashrc
- zshrc
- fishconfig
- fishfunctions


[1]: https://www.digitalocean.com/community/tutorials/how-to-use-git-to-manage-your-user-configuration-files-on-a-linux-vps#creating-a-configuration-directory-to-store-files