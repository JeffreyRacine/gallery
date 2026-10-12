# Difference-in-differences with changing composition: a same-data np robustness check.
# Sant'Anna and Xu (2026), Journal of Econometrics 253, 106147, Table 4.
# https://doi.org/10.1016/j.jeconom.2025.106147
# Requires np >= 0.80-1 and internet access; no package installation is performed.
# Run source("np_composition_did.R") in R or RStudio. Both nuisance stages and
# all bandwidths are freshly estimated. Allow a few minutes for the seven fits.
# Results remain in did_results; no folders, downloads on disk or output files
# are created. The published column is a fixed reference, never a tuning target.

did_results <- local({
  if (!requireNamespace("np", quietly = TRUE) ||
      utils::packageVersion("np") < "0.80.1")
    stop("Install np 0.80-1 or later before running this example.")
  old_options <- options(np.messages = FALSE)
  on.exit(options(old_options))
  started <- proc.time()[["elapsed"]]

  # A. Read the authors' pinned public dataset directly into memory.
  revision <- "894bd65a952c30f01a4e0005efba4cb335065eb7"
  data_url <- paste0("https://raw.githubusercontent.com/pedrohcgs/comp_did/",
                     revision, "/data/sequeira_bribes.rda")
  message("Reading pinned Sequeira application data")
  input <- new.env(parent = emptyenv())
  read_data <- function() {
    con <- url(data_url, open = "rb")
    on.exit(close(con))
    bytes <- readBin(con, what = "raw", n = 10000000L)
    # The pinned .rda is xz-compressed; decompress in memory before loading.
    object_con <- rawConnection(memDecompress(bytes, type = "xz"))
    on.exit(close(object_con), add = TRUE)
    load(object_con, envir = input)
  }
  read_data()
  dat <- input$sequeira_bribes
  if (!is.data.frame(dat)) stop("The pinned data object is unavailable.")

  # Match the archived application preprocessing and common complete-case sample.
  dat$lba_value[2783L] <- 0
  dat$monitor <- dat$monitor - 1
  dat$psi <- 2 - dat$psi
  dat$ltonnage <- log(dat$tonnage + 1)
  outcomes <- c("bp", "lba", "lba_value", "lba_tonnage")
  continuous <- list(c("lvalue_tonnage", "tariff2007"),
                     c("lvalue_tonnage", "tariff2007"),
                     c("ltonnage", "tariff2007"),
                     c("lvalue_shipment_metical", "tariff2007"))
  unordered <- c("differentiated", "agri", "perishable", "dfs", "day_w_arrival",
                 "monitor", "psi", "rsa", "term")
  keep <- c(outcomes, "post_2008", "tariff_change_2008", "lvalue_tonnage",
            "ltonnage", "lvalue_shipment_metical", "tariff2007", unordered,
            "hc_4digits", "clear_agent", "hc_group")
  dat <- dat[complete.cases(dat[, keep]), , drop = FALSE]
  d <- dat$tariff_change_2008
  post <- dat$post_2008
  cells <- cbind("11" = d * post, "10" = d * (1 - post),
                 "01" = (1 - d) * post, "00" = (1 - d) * (1 - post))
  cluster <- as.integer(factor(dat$hc_4digits))
  n <- nrow(dat)
  stopifnot(n == 1084L, identical(as.numeric(colSums(cells)), c(120, 56, 824, 84)),
            max(cluster) == 131L, all(rowSums(cells) == 1))
  make_x <- function(i) {
    cn <- continuous[[i]]
    x <- dat[c(cn, unordered)]
    x[cn] <- lapply(x[cn], function(v) (v - min(v)) / diff(range(v)))
    x[unordered] <- lapply(x[unordered], function(v) factor(v, levels = sort(unique(v))))
    x
  }

  # B. Generalized propensities: four-cell conditional class probabilities.
  # Gaussian LC npconmode replaces local multinomial-logit likelihood.
  # CVML selects one bandwidth per predictor plus response-class smoothing.
  fit_propensity <- function(i) {
    x <- make_x(i)
    y <- factor(max.col(cells), levels = 1:4, labels = colnames(cells))
    seed <- 852000L + 100L * i
    set.seed(seed)
    message("Propensity design ", i, ": selecting Gaussian LC bandwidths")
    bw <- np::npcdensbw(xdat = x, ydat = y, regtype = "lc", bwmethod = "cv.ml",
      cxkertype = "gaussian", uxkertype = "liracine", uykertype = "aitchisonaitken",
      nmulti = 2L)
    probability <- matrix(NA_real_, n, 4, dimnames = list(NULL, levels(y)))
    message("Propensity design ", i, ": leave-one-out class probabilities")
    for (j in seq_len(n)) {
      fit <- np::npconmode(bws = bw, txdat = x[-j, , drop = FALSE], tydat = y[-j],
        exdat = x[j, , drop = FALSE], probabilities = TRUE, proper = FALSE, se = FALSE)
      p <- predict(fit, type = "prob")
      stopifnot(setequal(colnames(p), levels(y)))
      probability[j, ] <- p[, levels(y)]
      if (j %% 100L == 0L) message("  observations ", j, "/", n)
    }
    stopifnot(all(is.finite(probability)), min(probability) > -1e-12,
              max(abs(rowSums(probability) - 1)) < 1e-10)
    list(raw = probability, bws = bw, seed = seed)
  }

  # C. Outcomes: local-linear np regressions with two shared bandwidths.
  # One continuous bandwidth and one unordered bandwidth are shared by the four
  # cells. The continuous parameter retains the research comparison's halfwidth
  # units: np receives theta[1]/sqrt(5), also for the Gaussian specification.
  shared_bw <- function(x, y, theta) {
    np::npregbw(xdat = x, ydat = y,
      bws = c(rep(theta[1] / sqrt(5), 2), rep(theta[2], 9)),
      bandwidth.compute = FALSE, regtype = "ll",
      ckertype = "gaussian", ukertype = "liracine")
  }
  fit_outcome <- function(i) {
    x <- make_x(i)
    y <- dat[[outcomes[i]]]
    train <- lapply(1:4, function(g) which(cells[, g] == 1))
    loo_fit <- function(theta, return_fit = FALSE) {
      predicted <- numeric(n)
      bandwidths <- vector("list", 4)
      for (g in 1:4) {
        tr <- train[[g]]
        bw <- shared_bw(x[tr, , drop = FALSE], y[tr], theta)
        predicted[tr] <- as.numeric(np::npreghat(bws = bw,
          txdat = x[tr, , drop = FALSE], y = y[tr], leave.one.out = TRUE, output = "apply"))
        bandwidths[[g]] <- bw
      }
      stopifnot(all(is.finite(predicted)))
      if (return_fit) list(loo = predicted, bws = bandwidths)
      else mean((y - predicted)^2)
    }
    decode <- function(z) c(exp(z[1]), plogis(z[2]))
    evaluations <- list()
    objective <- function(z) {
      theta <- decode(z)
      condition <- ""
      value <- tryCatch(loo_fit(theta), error = function(e) {
        condition <<- conditionMessage(e)
        NA_real_
      })
      feasible <- length(value) == 1L && is.finite(value)
      evaluations[[length(evaluations) + 1L]] <<-
        list(theta = theta, value = value, feasible = feasible, error = condition)
      if (length(evaluations) %% 25L == 0L)
        message("  outcome CV evaluations ", length(evaluations), ": ", signif(value, 6))
      # Undefined search points are explicitly recorded and assigned the declared
      # infeasibility value. A failed final fit is never replaced or suppressed.
      if (feasible) value else 1e8
    }
    message("Outcome ", i, "/4 (", outcomes[i], "): pooled bandwidth selection")
    starts <- list(c(.8, .8), c(.35, .25))
    runs <- lapply(starts, function(s) optim(c(log(s[1]), qlogis(s[2])), objective,
      method = "Nelder-Mead", control = list(maxit = 250, reltol = 1e-7)))
    eligible <- vapply(runs, function(r)
      r$convergence == 0L && is.finite(r$value) && r$value < 1e8, logical(1))
    if (!any(eligible)) stop("No converged finite shared-bandwidth search for ", outcomes[i])
    j <- which(eligible)[which.min(vapply(runs[eligible], `[[`, numeric(1), "value"))]
    selected <- list(theta = decode(runs[[j]]$par), value = runs[[j]]$value,
                     selected_start = j, convergence = runs[[j]]$convergence)
    fit <- loo_fit(selected$theta, TRUE)
    mu <- matrix(NA_real_, n, 4)
    mu[, 1] <- 0 # The treated/post outcome regression cancels from this score.
    te <- train[[1]]
    for (g in 2:4) {
      tr <- train[[g]]
      mu[tr, g] <- fit$loo[tr]
      mu[te, g] <- as.numeric(fitted(np::npreg(bws = fit$bws[[g]],
        txdat = x[tr, , drop = FALSE], tydat = y[tr],
        exdat = x[te, , drop = FALSE], se = FALSE)))
      if (any(!is.finite(mu[c(tr, te), g])))
        stop("Undefined required outcome prediction for ", outcomes[i], ", cell ", g)
    }
    list(mu = mu, bws = fit$bws, selection = selected, loo = fit$loo,
         searches = runs, evaluations = evaluations)
  }

  # D. Normalized composition-robust ATT and influence function, coded in R.
  # The order of the four cells is (treated/post, treated/pre, control/post, control/pre).
  score <- function(y, ps, mu) {
    signs <- c(1, -1, -1, 1)
    raw <- matrix(0, n, 4)
    raw[, 1] <- cells[, 1]
    for (g in 2:4) {
      used <- cells[, g] == 1
      raw[used, g] <- ps[used, 1] / ps[used, g]
    }
    weights <- sweep(raw, 2, colMeans(raw), "/")
    summand <- weights[, 1] * y
    for (g in 2:4) {
      used <- cells[, 1] == 1 | cells[, g] == 1
      stopifnot(all(is.finite(mu[used, g])))
      summand <- summand + signs[g] * weights[, g] * y
      summand[used] <- summand[used] + signs[g] *
        (weights[used, 1] - weights[used, g]) * mu[used, g]
    }
    att <- mean(summand)
    list(att = att, influence = summand - weights[, 1] * att, weights = weights)
  }

  # The first two outcomes use the same predictors and therefore the same PS fit.
  propensities <- list()
  fits <- vector("list", 4)
  for (i in 1:4) {
    design <- if (i == 2L) 1L else i
    key <- as.character(design)
    if (is.null(propensities[[key]])) propensities[[key]] <- fit_propensity(design)
    outcome <- fit_outcome(i)
    raw <- propensities[[key]]$raw
    # Match the archived [0.01, 0.99] clipping convention; no renormalization.
    clipped <- pmin(pmax(raw, .01), .99)
    fits[[i]] <- list(propensity_design = design, outcome = outcome,
      score = score(dat[[outcomes[i]]], clipped, outcome$mu))
    message("Completed outcome ", i, "/4")
  }

  # E. Cluster multipliers, holding nuisance fits and selected bandwidths fixed.
  # 9,999 two-point Mammen draws per outcome; seed and draw order match the reference.
  B <- 9999L
  set.seed(1234)
  standard_error <- numeric(4)
  for (i in 1:4) {
    lo <- (1 - sqrt(5)) / 2
    hi <- (1 + sqrt(5)) / 2
    multipliers <- matrix(ifelse(rbinom(max(cluster) * B, 1, hi / sqrt(5)) == 1,
                                 lo, hi), max(cluster), B)
    sums <- drop(rowsum(fits[[i]]$score$influence, cluster, reorder = TRUE))
    draws <- drop(crossprod(sums, multipliers)) / n
    standard_error[i] <- IQR(draws) / (qnorm(.75) - qnorm(.25))
  }
  # Published composition-robust Table 4 rows, at archived numerical precision.
  # These constants enter only the final comparison, after all fitting is finished.
  comparison <- data.frame(
    outcome = c("Bribe probability", "Log(1 + bribe)",
                "Log(1 + bribe / shipment value)", "Log(1 + bribe / shipment tonnage)"),
    paper_ATT = c(-.306830232539233, -2.888421692017772,
                  -.027433270204529, -1.130749520587983),
    paper_cluster_se = c(.1085927324954277, .9147965196707813,
                         .0144722510275693, .6346428587348426),
    np_ATT = vapply(fits, function(f) f$score$att, numeric(1)),
    np_cluster_se = standard_error)
  comparison$np_lower <- comparison$np_ATT - qnorm(.975) * standard_error
  comparison$np_upper <- comparison$np_ATT + qnorm(.975) * standard_error
  table <- data.frame(Outcome = comparison$outcome,
    `Sant'Anna-Xu: ATT (SE)` = sprintf("%.4f (%.4f)", comparison$paper_ATT, comparison$paper_cluster_se),
    `np: ATT (SE)` = sprintf("%.4f (%.4f)", comparison$np_ATT, comparison$np_cluster_se),
    check.names = FALSE)
  print(table, row.names = FALSE, right = FALSE)
  elapsed <- proc.time()[["elapsed"]] - started
  message("Fresh estimation complete in ", round(elapsed, 1), " seconds. Results: did_results")
  list(comparison = comparison, table = table, data = dat, cells = cells,
       cluster = cluster, propensities = propensities, fits = fits,
       provenance = list(data_url = data_url, revision = revision,
         probability_clip = c(.01, .99), continuous_kernel = "gaussian",
         multiplier_seed = 1234L, multiplier_draws = B),
       elapsed_seconds = elapsed, session_info = sessionInfo())
})
