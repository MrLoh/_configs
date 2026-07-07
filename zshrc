# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

# resolve partial versions in .nvmrc/.node-version to the newest installed match
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

source /opt/homebrew/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# setup postgres
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# add android device manager
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export PATH="~/Library/Android/sdk/platform-tools/:$PATH"
export PATH="~/Library/Android/sdk/tools/:$PATH"
export PATH="~/Library/Android/sdk/emulator:$PATH"

# Azul Zulu OpenJDK 17
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# disable .pyc files
export PYTHONDONTWRITEBYTECODE=1

# export variables
export NODE_OPTIONS="--max_old_space_size=8192"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pipx
export PATH="$PATH:~/.local/bin"

# setup milvus
export PATH="$PATH:~/.milvus/bin"

# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# orbstack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

alias claude="~/.claude/local/claude"
export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"

# ls / ll / la (mirrors fish's built-in color-aware helpers)
alias ls='ls -G'
alias ll='ls -lhG'
alias la='ls -lAhG'

# kiro
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# zsh-autosuggestions and zsh-syntax-highlighting (fish has these built in).
# zsh-syntax-highlighting must be sourced last, after all other widgets are defined.
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
