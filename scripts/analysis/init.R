library(config)
library(rstudioapi)

# set wd manually if you run this by hand!
# setwd("~/Github/datos/scripts/analysis")
setwd(dirname(rprojroot::thisfile()))

##############################################
# L o a d i n g . h a z e l . p a c k a g e...
# https://stackoverflow.com/questions/1815606/determine-path-of-the-executing-script

###################################
# F u n c t i o n s
print("Loading Functions")
lapply(list.files("functions"), function(file) {
  source(paste0("functions/", file))
})

# detaching all packages
detach_all_packages()

###################################
# L o a d i n g . d a t a s e t s
#
config <- config::get()

print("Loading libraries")
load_libraries(config$settings$libraries)

print("Loading libraries from source")
load_github(config$settings$github)

print("Loading files")

data <- list(
  covid = init_files(config$data$covid_folder),
  daily_tables = init_files(config$data$daily_tables_folder)
)
