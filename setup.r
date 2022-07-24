# set CRAN mirror
local({
  repos <- getOption("repos")
  repos["CRAN"] <- "https://cloud.r-project.org"
  options(repos = repos)
})
# install packages
install.packages(
  c(
    "repr",
    "IRdisplay",
    "evaluate",
    "crayon",
    "pbdZMQ",
    "devtools",
    "uuid",
    "digest",
    "tidyverse",
    "languageserver"
  )
)
# install IR kernel
system("python3 -m pip install ipykernel")
system("python3 -m ipykernel install")
devtools::install_github("IRkernel/IRkernel")
IRkernel::installspec()
