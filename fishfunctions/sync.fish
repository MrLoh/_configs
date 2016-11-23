function sync --description 'issues git aa, git ca and git push origin'
  git aa :/
  git ca $argv
  git push origin master
end
