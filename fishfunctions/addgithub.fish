function addgithub --description 'initializes new github repo and issues initial commit and push'
  git init
  touch README.md
  hub create -d
  sync "initial commit"
end
