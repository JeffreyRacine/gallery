## Explore local-linear partial regression plots while varying the
## off-axis education, experience, and tenure quantiles.

library(manipulate)
library(np)

## Load the wage1 data which contains the precomputed bandwidth object
## `bw.all'

data(wage1)

## Redraw the partial views after a control changes.

manipulate(plot(bw.all,
                common_scale = common_scale,
                errors = "asymptotic",
                xq = c(0.5, 0.5, educ, exper, tenure)),
           common_scale = picker(TRUE, FALSE, label = "Common Scale for Y Axes"),
           educ = slider(0, 1, 0.5, label = "Education Quantile", step = 0.1, ticks = TRUE),
           exper = slider(0, 1, 0.5, label = "Experience Quantile", step = 0.1, ticks = TRUE),
           tenure = slider(0, 1, 0.5, label = "Tenure Quantile", step = 0.1, ticks = TRUE))
