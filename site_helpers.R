read_quickstarts_manifest <- function(path = "data/quickstarts_manifest.csv") {
  manifest <- utils::read.csv(
    path,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA")
  )

  required <- c(
    "id",
    "section",
    "section_order",
    "display_title",
    "goal",
    "file_name",
    "path",
    "topic",
    "functions",
    "start_label",
    "start_path",
    "blurb",
    "featured_rank",
    "featured_heading",
    "featured_note"
  )

  missing <- setdiff(required, names(manifest))
  if (length(missing) > 0L) {
    stop(
      "Quickstart manifest is missing required columns: ",
      paste(missing, collapse = ", ")
    )
  }

  manifest$section_order <- as.integer(manifest$section_order)
  manifest$featured_rank <- as.integer(manifest$featured_rank)

  featured_order <- ifelse(is.na(manifest$featured_rank), 999L, manifest$featured_rank)
  manifest <- manifest[order(manifest$section_order, featured_order, manifest$file_name), ]
  rownames(manifest) <- NULL
  manifest
}

markdown_link <- function(label, path) {
  sprintf("[%s](%s)", label, path)
}

escape_md_cell <- function(x) {
  x <- ifelse(is.na(x), "", x)
  x <- gsub("\\|", "\\\\|", x)
  x
}

source_block <- function(path) {
  lines <- readLines(path, warn = FALSE)
  paste(c("```r", lines, "```"), collapse = "\n")
}

emit_markdown <- function(text = "") {
  cat(text, sep = "")
}

emit_source <- function(path) {
  emit_markdown(paste0(source_block(path), "\n"))
}

render_markdown_table <- function(df, columns) {
  if (nrow(df) == 0L) {
    emit_markdown("_No items listed yet._\n")
    return(invisible(NULL))
  }

  header <- paste0("| ", paste(columns, collapse = " | "), " |")
  divider <- paste0("|", paste(rep("---", length(columns)), collapse = "|"), "|")

  rows <- apply(df[, columns, drop = FALSE], 1L, function(row) {
    values <- vapply(row, escape_md_cell, character(1))
    paste0("| ", paste(values, collapse = " | "), " |")
  })

  emit_markdown(paste(c(header, divider, rows), collapse = "\n"))
  emit_markdown("\n")
}

package_label <- function(section) {
  switch(
    section,
    np = "`np`",
    npRmpi = "`npRmpi`",
    crs = "`crs`",
    section
  )
}

render_quickstart_choose_table <- function(df) {
  table <- data.frame(
    "If you want to..." = df$goal,
    "Start here" = markdown_link(df$file_name, df$path),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  render_markdown_table(table, c("If you want to...", "Start here"))
}

render_featured_quickstarts <- function(df) {
  featured <- df[!is.na(df$featured_rank), , drop = FALSE]
  featured <- featured[order(featured$featured_rank), , drop = FALSE]

  if (nrow(featured) == 0L) {
    emit_markdown("_No featured quickstarts listed yet._\n")
    return(invisible(NULL))
  }

  pieces <- character()
  for (i in seq_len(nrow(featured))) {
    row <- featured[i, ]
    pieces <- c(
      pieces,
      sprintf("### %s", row$featured_heading),
      "",
      sprintf("Source file: %s", markdown_link(row$file_name, row$path)),
      "",
      source_block(row$path),
      "",
      row$featured_note,
      ""
    )
  }

  emit_markdown(paste(pieces, collapse = "\n"))
}

render_quickstart_catalog_table <- function(df) {
  table <- data.frame(
    Script = markdown_link(df$file_name, df$path),
    "Main topic" = df$topic,
    "Functions/features" = df$functions,
    "Start reading here" = markdown_link(df$start_label, df$start_path),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  render_markdown_table(
    table,
    c("Script", "Main topic", "Functions/features", "Start reading here")
  )
}

render_quickstart_callouts <- function(df, prefix_package = FALSE) {
  if (nrow(df) == 0L) {
    emit_markdown("_No quickstarts listed yet._\n")
    return(invisible(NULL))
  }

  pieces <- character()
  for (i in seq_len(nrow(df))) {
    row <- df[i, ]
    title <- row$display_title
    if (isTRUE(prefix_package)) {
      title <- sprintf("%s: %s", package_label(row$section), row$display_title)
    }

    pieces <- c(
      pieces,
      "::: {.callout-note collapse=\"true\"}",
      sprintf("## %s", title),
      "",
      sprintf("Source file: %s", markdown_link(row$file_name, row$path)),
      "",
      source_block(row$path),
      ":::",
      ""
    )
  }

  emit_markdown(paste(pieces, collapse = "\n"))
}
