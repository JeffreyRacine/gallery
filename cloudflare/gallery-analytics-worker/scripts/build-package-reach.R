args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("Usage: build-package-reach.R OUTPUT.json", call. = FALSE)
}

packages <- c("np", "npRmpi", "crs")

# packageRank provides the latest daily CRAN-mirror percentile distribution.
rank_fit <- packageRank::packageRank(
  package = packages,
  check.package = FALSE,
  multi.core = FALSE
)
rank_date <- as.Date(rank_fit$date)
rank_rows <- rank_fit$cran.data[match(packages, rank_fit$cran.data$package), ]
if (anyNA(rank_rows$package)) {
  stop("The latest CRAN log does not contain every tracked package", call. = FALSE)
}

# Use the same source-through date for the rolling download windows.
download_rows <- cranlogs::cran_downloads(
  packages = packages,
  from = rank_date - 364L,
  to = rank_date
)
downloads_for <- function(package, days) {
  first_date <- rank_date - (days - 1L)
  rows <- download_rows$package == package & download_rows$date >= first_date
  as.integer(sum(download_rows$count[rows]))
}

# Count direct CRAN relationships, separating required from optional use.
cran_repository <- "https://cloud.r-project.org"
cran_packages <- utils::available.packages(
  contriburl = utils::contrib.url(cran_repository, type = "source"),
  type = "source",
  repos = cran_repository
)
required_dependencies <- tools::package_dependencies(
  packages,
  db = cran_packages,
  which = c("Depends", "Imports", "LinkingTo"),
  recursive = FALSE,
  reverse = TRUE
)
optional_dependencies <- tools::package_dependencies(
  packages,
  db = cran_packages,
  which = c("Suggests", "Enhances"),
  recursive = FALSE,
  reverse = TRUE
)

package_rows <- lapply(seq_along(packages), function(index) {
  package <- packages[[index]]
  required <- unique(required_dependencies[[package]])
  optional <- unique(optional_dependencies[[package]])
  list(
    package = package,
    downloads30 = downloads_for(package, 30L),
    downloads365 = downloads_for(package, 365L),
    downloadsOnRankDate = as.integer(rank_rows$count[[index]]),
    dailyRank = as.integer(rank_rows$rank[[index]]),
    dailyRankTotal = as.integer(nrow(rank_fit$cran.data)),
    dailyPercentile = as.numeric(rank_rows$percentile[[index]]),
    reverseDependencies = list(
      required = length(required),
      all = length(unique(c(required, optional)))
    )
  )
})

snapshot <- list(
  schemaVersion = 1L,
  generatedAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  status = "current",
  sourceThrough = as.character(rank_date),
  rankDate = as.character(rank_date),
  windows = list(
    last30Days = list(
      from = as.character(rank_date - 29L),
      to = as.character(rank_date)
    ),
    last365Days = list(
      from = as.character(rank_date - 364L),
      to = as.character(rank_date)
    )
  ),
  packages = package_rows
)

jsonlite::write_json(snapshot, args[[1]], auto_unbox = TRUE, pretty = TRUE)
