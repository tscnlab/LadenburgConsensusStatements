#preparing language data

library(purrr)
library(rlang)
library(dplyr)
library(readxl)
library(glue)

prepare_lang_data <- function(language){
  #loading data
  path <- "assets/LadenburgConsensuStatements.xlsx"
  sheets <- readxl::excel_sheets(path)
  stopifnot("language argument must be part of the 'LadenburgConsensuStatements.xlsx' worksheets" = 
              !language %in% names(sheets))
  data <- read_xlsx(path, sheet = language)
  data_ref <- read_xlsx(path, sheet = "English")
  #copying references from English worksheet
  data[6] <- data_ref[6]
  #get the names
  headers <<- names(data)
  names(data) <- c("chapter", "number", "statement", "simplified", "context", "reference")
  dataset <<- data
}

