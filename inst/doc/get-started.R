## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## ----dev-load, include=FALSE--------------------------------------------------
# Prefer source build when available (works in RStudio, pkgdown, or local render)
if (requireNamespace("devtools", quietly = TRUE) && file.exists(file.path("..","DESCRIPTION"))) {
  # Don't error on CRAN/build machines that don't have devtools or the source path
  try(devtools::load_all("..", quiet = TRUE), silent = TRUE)
}

# If we've already loaded from source, avoid re-attaching a different installed build later
from_source <- try({
  "DAGassist" %in% loadedNamespaces() &&
    grepl(normalizePath(".."), getNamespaceInfo(asNamespace("DAGassist"), "path"), fixed = TRUE)
}, silent = TRUE)
from_source <- isTRUE(from_source)

# Feature gates (computed *after* attempting load_all)
has_show <- tryCatch({
  "show" %in% names(formals(DAGassist::DAGassist))
}, error = function(e) FALSE)

# Robust check: dev build defines a private .report_dotwhisker helper
has_dotwhisker <- tryCatch({
  exists(".report_dotwhisker", envir = asNamespace("DAGassist"), inherits = FALSE)
}, error = function(e) FALSE)

## ----ex-dag, include=FALSE----------------------------------------------------
library(dagitty)
library(ggdag)

dag_model <- dagify(
  Y ~ X + M + Z + A + B,
  X ~ Z,
  C ~ X + Y,
  M ~ X,
  exposure = "X",
  outcome  = "Y"
)

set.seed(42)
n <- 2000

#exogenous variables
A <- rnorm(n, 0, 1)
B <- rnorm(n, 0, 1)
Z <- rnorm(n, 0, 1)

#structural equations
# X ~ Z
beta_zx <- 0.8
X <- beta_zx * Z + rnorm(n, 0, 1)

# M ~ X
beta_xm <- 0.9
M <- beta_xm * X + rnorm(n, 0, 1)

# Y ~ X + M + Z + A + B
bX <- 0.7; bM <- 0.6; bZ <- 0.3; bA <- 0.2; bB <- -0.1
Y <- bX*X + bM*M + bZ*Z + bA*A + bB*B + rnorm(n, 0, 1)

# C ~ X + Y 
bXC <- 0.5; bYC <- 0.4
C <- bXC*X + bYC*Y + rnorm(n, 0, 1)

reg_levels <- c("North", "South", "East", "West")
region <- factor(sample(reg_levels, n, replace = TRUE))

df <- data.frame(A, B, Z, X, M, Y, C, region)

## ----example, eval=FALSE------------------------------------------------------
# library(DAGassist)
# library(dagitty)
# 
# DAGassist(
#   dag = your_dag_model,
#   formula = your_regression_call
# )

## ----formula, eval=FALSE------------------------------------------------------
# #imputed formula
# DAGassist(
#   #implies the exposure and outcome from the dagitty object
#   dag = dag_model,
#   #implies the engine, formula, and data from the regression call
#   formula = lm(Y ~ X + C, data=df)
# )
# 
# #plain formula
# DAGassist(
#   dag = dag_model,
#   engine = stats::lm, #stats::lm is the default engine arg
#   formula = Y ~ X + C,
#   data = df,
#   exposure = "X",
#   outcome = "Y"
# )

## ----imply-demo---------------------------------------------------------------
#pruned-to-formula DAG
DAGassist(dag = dag_model, formula = Y ~ X + C, data = df, imply = FALSE, show = "roles")

#full-DAG evaluation
DAGassist(dag = dag_model, formula = Y ~ X + C, data = df, imply = TRUE,  show = "roles")

## ----omit, eval=FALSE---------------------------------------------------------
# DAGassist(
#     dag = dag_model,
#     formula = fixest::feols(Y ~ X + C + fixest::i(region), data = df),
#     imply = TRUE,
#     eval_all = TRUE
#     )

## ----show-demo, eval=FALSE----------------------------------------------------
# # just the roles table
# DAGassist(dag = dag_model, formula = Y ~ X + Z + C, data = df, show = "roles")
# #just the model comparison
# DAGassist(dag = dag_model, formula = Y ~ X + Z + C, data = df, show = "models")

## ----labels-------------------------------------------------------------------
labs <- list(
  X = "Exposure",
  Y = "Outcome",
  C = "Collider"
)

DAGassist(
  dag = dag_model, formula = lm(Y ~ X + C, data = df),
  show = "roles", labels = labs
)

## ----omit-demo, eval=FALSE----------------------------------------------------
# DAGassist(
#     dag = dag_model,
#     formula = fixest::feols(Y ~ X + Z + i(region), data = df),
#     omit_intercept = TRUE, omit_factors = TRUE # both TRUE by default
#   )

## ----bivariate----------------------------------------------------------------
DAGassist(
  dag = dag_model, 
  formula = lm(Y ~ X + C, data = df),
  show = "models",
  bivariate = TRUE
)

## ----verbose-demo, eval=FALSE-------------------------------------------------
# DAGassist(dag = dag_model, formula = Y ~ X + Z + C, data = df, verbose = FALSE)

