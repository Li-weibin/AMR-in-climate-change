if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("Rgraphviz")
install.packages("INLA", 
                 repos=c(getOption("repos"), 
                         INLA="https://inla.r-inla-download.org/R/stable"), 
                 dep=TRUE)

library(INLA)

# load data ----
AMR <- read.csv("rawdata.csv")
# spatial adjacency matrix
W <- readRDS("W.rds")

# Spatial-temporal mixed effects model with structured random effects ----
# formula
formula_car <- R_geomean_logit ~ GM_PM25 + sro_year + ssro_year + TempChange + 
  Urban + CPI + CHERate + OutPocketRate + lnPopDensity + lnTravel + 
  WASHIndex + ImmIndex + AMC + IncomeGroup + 
  f(year, model = "rw1") +
  f(country, model = "besag", graph = W)

# model
fit <- inla(formula(formula_car), data = AMR, family = "gaussian",
            control.predictor = list(compute = TRUE),
            control.compute = list(dic = TRUE, waic = TRUE, config = TRUE))

# Estimation ----
# fixed effects
fit$summary.fixed
# prediction
fit$summary.linear.predictor
# dic
fit$dic$dic
