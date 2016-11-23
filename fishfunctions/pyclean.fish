function pyclean --description 'delete all .pyc and __pycache__ files'
  for filename in (find . -name "*.pyc")
    rm $filename
  end
  for dirname in (find . -name "__pycache__")
    rm -r $dirname
  end
  for dirname in (find . -name ".ipynb_checkpoints")
    rm -r $dirname
  end
end