#this script renders all the language subsites
library(glue)
library(purrr)
library(stringr)
library(quarto)

source("scripts/update_qmd.R")

path <- "assets/translations"
files <- list.files(path, pattern = glue(".xlsx$"))
languages <- files |> str_extract("^([A-Za-z]+)\\.", group = 1)
language_param <- glue("  langs: {languages}")
lang_indicator <- files |> str_extract("\\.([a-z]{2,3})-", group = 1)
yaml_file <- glue('  - "assets/translations/authors_{languages}.yml"')
quarto_file <- glue("consensus-statements_{lang_indicator}.qmd")

translation_info <- list(files, languages, lang_indicator, yaml_file, language_param, quarto_file)
translation_info <- translation_info |> list_transpose()

translation_info |>
  walk(
\(x) {
  if(!file.exists(x[6])) {
    file.copy("consensus-statements_en.qmd", x[6])
    cat("created file:", x[6], "\n")
  }
  replace_qmd_lines_3_and_5(x[6], line3_text = x[5], line5_text = x[4])
}
)
