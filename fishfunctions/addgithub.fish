function addgithub --description 'initializes new github repo and issues initial commit and push'
  git init
  touch README.md
  gh repo create --source=. --private --push
  sync "initial commit"
end
