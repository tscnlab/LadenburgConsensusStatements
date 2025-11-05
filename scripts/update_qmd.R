replace_qmd_lines_3_and_5 <- function(path, line3_text, line5_text,
                                      backup = FALSE, create_missing = FALSE,
                                      progress = TRUE) {
  if (!file.exists(path)) stop("File not found: ", path)
  
  # Read all lines (quietly)
  lines <- tryCatch(readLines(path, warn = FALSE, encoding = "UTF-8"),
                    error = function(e) stop("Couldn't read file: ", e$message))
  
  # Ensure we have at least 5 lines, or stop/pad as requested
  if (length(lines) < 5) {
    if (!create_missing) {
      stop("File has only ", length(lines), " lines. ",
           "Set create_missing = TRUE to pad it to 5 lines.")
    } else {
      lines <- c(lines, rep("", 5 - length(lines)))
    }
  }
  
  # Optional backup
  if (backup) {
    ok <- file.copy(path, paste0(path, ".bak"), overwrite = TRUE)
    if (!ok) warning("Couldn't create backup at ", paste0(path, ".bak"))
  }
  
  if(identical(lines[3], line3_text |> as.character()) &
     identical(lines[5], line5_text |> as.character())) return()
  
  # Replace the requested lines
  lines[3] <- line3_text
  lines[5] <- line5_text
  
  # Write back (preserve bytes)
  con <- file(path, open = "wb", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  writeLines(lines, con, useBytes = TRUE)
  
  if(progress) {
    cat("successfully updated:", path, "\n")
  }
  
  invisible(TRUE)
}
