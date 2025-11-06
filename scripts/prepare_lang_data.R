#preparing language data

library(purrr)
library(rlang)
library(dplyr)
library(readxl)
library(glue)
library(yaml)
library(stringr)


prepare_lang_data <- function(language){
  #loading data
  file <- list.files("assets/translations", pattern = glue("^{language}"),
                      full.names = TRUE)
  stopifnot("Language specification is not unambiguous or findable, check translation files in `assets/translations/`" =
              length(file) == 1)
  sheets <- readxl::excel_sheets(file)
  data <- read_xlsx(file, sheet = "Statements")
  misc <- read_xlsx(file, sheet = "Misc")
  data <- data |> select(2, 4, 6, 8, 10)
  data_ref <- read_xlsx("assets/translations/English.UK.en-UK.xlsx", sheet = "Statements")
  #copying references from English worksheet
  data[6] <- data_ref[11]
  #get the names
  headers <<- c(names(data)[1:5], misc$Translation[2])
  names(data) <- c("chapter", "number", "statement", "simplified", "context", "reference")
  dataset <<- data
  title_qmd <- misc$Translation[1]
  
  prepare_author_data(file, language, title_qmd)
  key_messages <<- prepare_key_messages(file)
  
}

prepare_key_messages <- function(file){
  data <- read_xlsx(file, sheet = "Key messages")
  data |> pull(2)
}

prepare_author_data <- function(file, language, title_qmd){
  data <- read_xlsx(file, sheet = "Contributors")
  
  lang_indicator <- file |> str_extract("\\.([a-z]{2,3})-", group = 1)
  
  authors <- apply(data, 1, function(x) {
    entry <- 
      list(
        name = paste(x["First name"], x["Last name"]),
        affiliation = if(!is.na(x["Affiliation"])) x["Affiliation"],
        orcid = if(!is.na(x["ORCID"])) x["ORCID"]
      )
    Filter(Negate(is.null), entry)
  })
  
  yaml_list <- list(author = authors,
                    lang = lang_indicator,
                    title = title_qmd
                    # params = list(langs = language)
  )
  
  if(language %in% c("Persian", "Arabic")) {
    yaml_list <- append(yaml_list, c(dir = "rtl"))
  }
  
  # Convert to YAML; authors can be length 1 or many
  yaml_text <- as.yaml(yaml_list, 
                       indent = 2, line.sep = "\n")
  # yaml_text <- as.yaml(list(author = authors))
  # cat(yaml_text)
  # write to a file Quarto can include
  writeLines(yaml_text, paste0("assets/translations/authors_", language, ".yml"))
}

