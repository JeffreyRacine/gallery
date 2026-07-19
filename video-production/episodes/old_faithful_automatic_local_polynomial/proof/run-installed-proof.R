args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop("usage: run_plot_proof.R B OUTPUT_PNG OUTPUT_RDS")
}

B <- as.integer(args[[1]])
png_path <- args[[2]]
rds_path <- args[[3]]

library(np)
data(faithful, package = "datasets")

fit_messages <- character()
fit_warnings <- character()
fit_time <- system.time({
  fit_npreg <- withCallingHandlers(
    npreg(waiting ~ eruptions, data = faithful, nomad = "auto"),
    message = function(cnd) {
      fit_messages <<- c(fit_messages, conditionMessage(cnd))
      invokeRestart("muffleMessage")
    },
    warning = function(cnd) {
      fit_warnings <<- c(fit_warnings, conditionMessage(cnd))
      invokeRestart("muffleWarning")
    }
  )
})

options(plot.par.mfrow = FALSE)
png(png_path, width = 1920, height = 1080, res = 150, type = "cairo")
par(mfrow = c(2, 2), mar = c(4.0, 4.3, 2.4, 1.0), oma = c(0, 0, 0, 0))

plot_calls <- list(
  list(label = "level", gradients = FALSE, gradient_order = NULL),
  list(label = "first derivative", gradients = TRUE, gradient_order = 1L),
  list(label = "second derivative", gradients = TRUE, gradient_order = 2L),
  list(label = "third derivative", gradients = TRUE, gradient_order = 3L)
)

plot_results <- vector("list", length(plot_calls))
for (i in seq_along(plot_calls)) {
  spec <- plot_calls[[i]]
  warnings <- character()
  messages <- character()
  elapsed <- system.time({
    value <- withCallingHandlers(
      if (is.null(spec$gradient_order)) {
        plot(fit_npreg, errors = "bootstrap", band = "all", B = B)
      } else {
        plot(fit_npreg,
             errors = "bootstrap", band = "all", B = B,
             gradients = spec$gradients,
             gradient_order = spec$gradient_order)
      },
      message = function(cnd) {
        messages <<- c(messages, conditionMessage(cnd))
        invokeRestart("muffleMessage")
      },
      warning = function(cnd) {
        warnings <<- c(warnings, conditionMessage(cnd))
        invokeRestart("muffleWarning")
      }
    )
  })
  plot_results[[i]] <- list(
    label = spec$label,
    elapsed = elapsed,
    warnings = warnings,
    messages = messages,
    returned_class = class(value),
    returned_names = names(value)
  )
}
dev.off()

result <- list(
  B = B,
  package_version = as.character(packageVersion("np")),
  package_path = find.package("np"),
  fit_time = fit_time,
  degree = fit_npreg$bws$degree,
  degree_search = fit_npreg$bws$degree.search,
  bandwidth = fit_npreg$bws$bw,
  objective = fit_npreg$bws$fval,
  fit_warnings = fit_warnings,
  fit_messages = fit_messages,
  plots = plot_results,
  png = normalizePath(png_path, mustWork = TRUE),
  session_info = sessionInfo()
)
saveRDS(result, rds_path)

cat("B=", B, "\n", sep = "")
cat("degree=", result$degree, "\n", sep = "")
cat("degree.search.mode=", result$degree_search$mode, "\n", sep = "")
cat("degree.search.reason=", result$degree_search$reason, "\n", sep = "")
cat("bandwidth=", format(result$bandwidth, digits = 16), "\n", sep = "")
cat("objective=", format(result$objective, digits = 16), "\n", sep = "")
cat("fit.elapsed=", unname(result$fit_time[["elapsed"]]), "\n", sep = "")
cat("fit.warnings=", length(fit_warnings), "\n", sep = "")
cat("fit.messages=", length(fit_messages), "\n", sep = "")
for (entry in plot_results) {
  cat("plot=", entry$label,
      ";elapsed=", unname(entry$elapsed[["elapsed"]]),
      ";warnings=", length(entry$warnings),
      ";messages=", length(entry$messages), "\n", sep = "")
  if (length(entry$warnings)) {
    cat("warning.text=", paste(entry$warnings, collapse = " | "), "\n", sep = "")
  }
}
cat("png=", result$png, "\n", sep = "")
print(result$session_info)
