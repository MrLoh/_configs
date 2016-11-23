function md2pdf --description 'convertes pandoc markdown to pdf with xetex'
	pandoc --filter pandoc-citeproc --latex-engine=xelatex -f markdown+raw_tex $argv
end
