function listabbr --description 'list all fish abbreviations'
  for val in $fish_user_abbreviations
      echo $val
  end
end
