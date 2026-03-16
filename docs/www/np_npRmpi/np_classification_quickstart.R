rm(list = ls())

## Minimal np classification / conditional-mode example.
##
## This keeps the first run compact while still showing the basic
## nonparametric classification route.

library(np)
data(birthwt, package = "MASS")

birthwt$low <- factor(birthwt$low)
birthwt$smoke <- factor(birthwt$smoke)
birthwt$race <- factor(birthwt$race)

fit <- npconmode(low ~ smoke + race + age + lwt, data = birthwt, nmulti = 1)

summary(fit)
fit$confusion.matrix

