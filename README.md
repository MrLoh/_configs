# @MrLoh Mac Config

This Repo contains my system wide configuration files and scripts. It is based on the setup
suggested in [this article][1].

### Usage

2. Create a Repos folder.
	- `mkdir ~/Repos && cd ~/Repos`
3. Clone this repo.
	- `git clone https://github.com/MrLoh/configs.git`
1. Install [Homebrew](https://brew.sh).
4. Review and trust the third-party Homebrew taps listed in the [Brewfile](./Brewfile).
	- `./trust-brew-taps.sh`
	- Required when `$HOMEBREW_REQUIRE_TAP_TRUST` is set.
5. Install Homebrew dependencies.
	- `brew bundle`
6. Set up GitHub SSH access.
	- Run `gh auth login`
	- Choose **GitHub.com**, **SSH**, and **Login with a web browser**.
8. Install [Operator Mono Lig](https://github.com/kiliman/operator-mono-lig) fonts.
9. Sign in to your account in [Warp](https://www.warp.dev) to sync terminal settings.
10. Create symlinks for profiles (!This will overwrite existing profiles).
	- `./link.sh`
11. Set up zsh as the default shell.
	- `./setup.zsh.sh`
12. Set up asdf and install defaults.
	- `./setup.asdf.sh`

Since the configurations are now symlinked, any further changes can easily be committed to git and
changes from other machines can easily be pulled down via git.

Optional setup:
- Configure [Fish Shell](https://fishshell.com) as an alternative shell (not the default).
	- `./setup.fish.sh` — installs oh-my-fish, theme, and iTerm integration
	- `fish` — start a fish session anytime
- Install Cursor extensions from `cursor/extensions.txt`.
	- `./cursor/setup-extensions.sh`
- Load Dash preferences from `~/Repos/_configs/dash/`.
	![Dash Preferences > General > Set Up Syncing](./ressources/dash_load_prefs.png)



### Content

This contains the following configs:
- gitconfig
- global gitignore
- bashrc
- zshrc
- p10k.zsh (with p10k)
- fishconfig (optional)
- asdf
- cursor (CLI & IDE, including `cursor/extensions.txt` for installed extensions)
- claude
- zed

Warp (the default terminal) is provisioned via the [Brewfile](./Brewfile) cask, but its own
settings (appearance, keybindings, shell default) are not tracked here — they're covered by
Warp's built-in account settings sync instead.

### Secrets

Some generated configs need a real secret that must never be committed. `link.sh` loads an untracked
`.env` file and uses its variables to fill in placeholders in templates.

Create `~/Repos/_configs/.env` with:
```
CONTEXT7_API_KEY=your-key-here
```
Then run `./link.sh`. If `.env` is missing or a variable is unset, the generated file will contain 
an empty placeholder instead.

### Cursor extensions

`cursor/extensions.txt` tracks installed Cursor extensions by ID (one per line, unpinned). Run
`./cursor/setup-extensions.sh` to install everything in the list; it only installs, it never
uninstalls extensions that aren't listed. After installing or removing an extension, run
`./cursor/export-extensions.sh` to refresh the list from your currently installed extensions, then
commit the change.

This helps setup the following tools:
- [iTerm 2](https://iterm2.com)
- [Homebrew](https://brew.sh)
- [zsh](https://www.zsh.org) with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (default shell)
- [Fish Shell](https://fishshell.com) (optional alternative)
- [Dash](https://kapeli.com/dash)
- [asdf](https://asdf-vm.com)

[1]: https://www.digitalocean.com/community/tutorials/how-to-use-git-to-manage-your-user-configuration-files-on-a-linux-vps#creating-a-configuration-directory-to-store-files