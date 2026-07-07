mkdir -p ~/.asdf/completions
asdf completion zsh > ~/.asdf/completions/_asdf

mkdir -p ~/.config/fish/completions
asdf completion fish > ~/.config/fish/completions/asdf.fish

asdf plugin add bun
asdf install bun latest
asdf set -u bun latest

asdf plugin add pnpm
asdf install pnpm latest
asdf set -u pnpm latest

asdf plugin add nodejs
asdf install nodejs latest:22
asdf set -u nodejs latest:22
./fix-asdf-corepack-shims.sh

asdf plugin add ruby
asdf install ruby latest
asdf set -u ruby latest

asdf plugin add python
asdf install python latest:3.12
asdf set -u python latest:3.12

asdf plugin add poetry https://github.com/asdf-community/asdf-poetry.git
asdf install poetry latest
asdf set -u poetry latest

asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf install terraform latest
asdf set -u terraform latest

asdf plugin add rust https://github.com/asdf-community/asdf-rust.git
asdf install rust latest
asdf set -u rust latest