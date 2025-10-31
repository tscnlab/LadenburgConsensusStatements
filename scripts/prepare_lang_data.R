#preparing language data

library(purrr)
library(rlang)
library(dplyr)
library(readxl)
library(glue)
library(yaml)


prepare_lang_data <- function(language){
  #loading data
  prepare_author_data(language)
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

prepare_author_data <- function(language){
  path <- "assets/LadenburgConsensuStatements.xlsx"
  data <- read_xlsx(path, sheet = "Contributors")
  
  data2 <- data |> filter(Language == language)
  
  authors <- apply(data2, 1, function(x) {
    entry <- 
      list(
        name = paste(x["First name"], x["Last name"]),
        affiliation = if(!is.na(x["Affiliation"])) x["Affiliation"],
        orcid = if(!is.na(x["ORCID"])) x["ORCID"]
      )
    Filter(Negate(is.null), entry)
  })
  
  # Convert to YAML; authors can be length 1 or many
  yaml_text <- as.yaml(list(author = authors), indent = 2, line.sep = "\n")
  # yaml_text <- as.yaml(list(author = authors))
  # cat(yaml_text)
  # write to a file Quarto can include
  writeLines(yaml_text, paste0("assets/translations/authors_", language, ".yml"))
}

