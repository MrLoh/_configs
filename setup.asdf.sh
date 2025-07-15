asdf completion fish > ~/.config/fish/completions/asdf.fish

asdf plugin add nodejs
asdf install nodejs latest:18
asdf global nodejs latest:18

asdf plugin add ruby
asdf install ruby latest
asdf global ruby latest

asdf plugin add python
asdf install python latest:12
asdf global python latest:12

asdf plugin add poetry https://github.com/asdf-community/asdf-poetry.git
asdf install poetry latest
asdf global poetry latest

asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdg install terraform latest
asdf global terraform latest

asdf plugin-add rust https://github.com/asdf-community/asdf-rust.git
asdf install rust latest
asdf global rust latest