args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("usage: run_proof.R OUTPUT_RDS OUTPUT_PNG")
}

library(np)
data(Italy, package = "np")

italy_numeric <- transform(
  Italy,
  year = as.numeric(as.character(year))
)

stopifnot(
  is.ordered(Italy$year),
  is.numeric(italy_numeric$year),
  identical(italy_numeric$year, as.numeric(levels(Italy$year))[Italy$year])
)

messages <- character()
warnings <- character()
capture_conditions <- function(expr) {
  withCallingHandlers(
    expr,
    message = function(cnd) {
      messages <<- c(messages, conditionMessage(cnd))
      invokeRestart("muffleMessage")
    },
    warning = function(cnd) {
      warnings <<- c(warnings, conditionMessage(cnd))
      invokeRestart("muffleWarning")
    }
  )
}

ordered_time <- system.time({
  fit_ordered <- capture_conditions(npreg(gdp ~ year, data = Italy))
})
numeric_time <- system.time({
  fit_numeric <- capture_conditions(npreg(gdp ~ year, data = italy_numeric))
})

fit_ordered_gradient <- capture_conditions(
  npreg(bws = fit_ordered$bws, gradients = TRUE)
)
fit_numeric_gradient <- capture_conditions(
  npreg(bws = fit_numeric$bws, gradients = TRUE)
)

png(args[[2]], width = 1920, height = 1080, res = 150, type = "cairo")
old_par <- par(no.readonly = TRUE)
options(plot.par.mfrow = FALSE)
par(
  mfrow = c(2, 2),
  mar = c(4.2, 4.5, 3.4, 1.0),
  oma = c(0.5, 0.5, 0.4, 0.3),
  cex.main = 1.05,
  cex.lab = 1.0,
  cex.axis = 0.9
)

plot_ordered <- capture_conditions(
  plot(fit_ordered,
       main = "Ordered year: fitted mean",
       xlab = "Year", ylab = "GDP")
)
plot_numeric <- capture_conditions(
  plot(fit_numeric,
       main = "Numeric year: fitted mean",
       xlab = "Year", ylab = "GDP")
)
gradient_ordered <- capture_conditions(
  plot(fit_ordered, gradients = TRUE,
       main = "Ordered year: finite difference",
       xlab = "Year")
)
gradient_numeric <- capture_conditions(
  plot(fit_numeric, gradients = TRUE,
       main = "Numeric year: derivative",
       xlab = "Year")
)

par(old_par)
dev.off()

result <- list(
  package_version = as.character(packageVersion("np")),
  package_path = find.package("np"),
  R_version = R.version.string,
  platform = R.version$platform,
  data = list(
    rows = nrow(Italy),
    columns = ncol(Italy),
    ordered_class = class(Italy$year),
    numeric_class = class(italy_numeric$year),
    years_equal = identical(
      italy_numeric$year,
      as.numeric(levels(Italy$year))[Italy$year]
    )
  ),
  ordered = list(
    elapsed = unname(ordered_time[["elapsed"]]),
    bws = fit_ordered$bws,
    fitted = fitted(fit_ordered),
    gradients = gradients(fit_ordered_gradient),
    plot = plot_ordered,
    gradient_plot = gradient_ordered
  ),
  numeric = list(
    elapsed = unname(numeric_time[["elapsed"]]),
    bws = fit_numeric$bws,
    fitted = fitted(fit_numeric),
    gradients = gradients(fit_numeric_gradient),
    plot = plot_numeric,
    gradient_plot = gradient_numeric
  ),
  warnings = warnings,
  messages = messages,
  session_info = sessionInfo()
)

saveRDS(result, args[[1]])

cat("np.version=", result$package_version, "\n", sep = "")
cat("np.path=", result$package_path, "\n", sep = "")
cat("rows=", result$data$rows, "\n", sep = "")
cat("ordered.class=", paste(result$data$ordered_class, collapse = "/"), "\n", sep = "")
cat("numeric.class=", paste(result$data$numeric_class, collapse = "/"), "\n", sep = "")
cat("year.values.equal=", result$data$years_equal, "\n", sep = "")
cat("ordered.elapsed=", result$ordered$elapsed, "\n", sep = "")
cat("numeric.elapsed=", result$numeric$elapsed, "\n", sep = "")
cat("ordered.bw=", paste(format(result$ordered$bws$bw, digits = 16), collapse = ","), "\n", sep = "")
cat("numeric.bw=", paste(format(result$numeric$bws$bw, digits = 16), collapse = ","), "\n", sep = "")
cat("ordered.kernel=", paste(result$ordered$bws$okertype, collapse = ","), "\n", sep = "")
cat("numeric.kernel=", paste(result$numeric$bws$ckertype, collapse = ","), "\n", sep = "")
cat("ordered.gradient.range=", paste(range(result$ordered$gradients), collapse = ","), "\n", sep = "")
cat("numeric.gradient.range=", paste(range(result$numeric$gradients), collapse = ","), "\n", sep = "")
cat("warnings=", length(result$warnings), "\n", sep = "")
cat("messages=", length(result$messages), "\n", sep = "")
print(result$session_info)
