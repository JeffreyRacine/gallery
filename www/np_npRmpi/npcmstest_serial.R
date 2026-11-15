## Serial counterpart to npcmstest_npRmpi.R.
## The test results should agree; elapsed times may differ.

library(np)
options(np.messages = FALSE)

data("oecdpanel")
model_data <- transform(oecdpanel,
  oecd = factor(oecd),
  year = factor(year))

model <- lm(growth ~ oecd +
            year +
            initgdp +
            I(initgdp^2) +
            I(initgdp^3) +
            I(initgdp^4) +
            popgro +
            inv +
            humancap +
            I(humancap^2) +
            I(humancap^3) - 1,
            data = model_data,
            x = TRUE,
            y = TRUE)

X <- model_data[c("oecd", "year", "initgdp", "popgro", "inv", "humancap")]
y <- model_data$growth

## Loose search tolerances keep this comparison brief; use the defaults
## for substantive work.

t <- system.time(output <- npcmstest(model = model,
                                     xdat = X,
                                     ydat = y,
                                     nmulti = 1,
                                     ftol = 0.01,
                                     tol = 0.01))

output

cat("Elapsed time =", t[3], "\n")
