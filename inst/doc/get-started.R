## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


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
# DAGassist(
#   dag = your_dag_model,
#   formula = your_regression_call
# )

## ----setup--------------------------------------------------------------------
library(DAGassist)
library(dagitty)

## ----formula, eval=FALSE------------------------------------------------------
# #formulaic formula
# DAGassist(
#   dag = dag_model,
#   formula = Y ~ X + C,
#   data = df,
#   exposure = "X",
#   outcome = "Y"
# )
# 
# #imputed formula
# DAGassist(
#   dag = dag_model,
#   formula = lm(Y ~ X + C, data=df)
# )

## ----imply-false--------------------------------------------------------------
DAGassist(
  dag = dag_model,
  formula = lm(Y~X+C, data = df),
  imply = FALSE
)

## ----imply-true---------------------------------------------------------------
DAGassist(
  dag = dag_model,
  formula = lm(Y~X+C, data = df),
  imply = TRUE
)

## ----omit---------------------------------------------------------------------
DAGassist(
  dag = dag_model,
  formula = fixest::feols(
    Y ~ X + C + i(region),  
    data = df),
  omit_factors = FALSE,
  omit_intercept = FALSE
)

## ----labels-------------------------------------------------------------------
labs <- list(
  X = "Exposure",
  C = "Collider"
)

DAGassist(
  dag = dag_model,
  formula = lm(
    Y ~ X + C, data = df),
  labels = labs
)

## ----rename-------------------------------------------------------------------
DAGassist(
  dag = dag_model,
  formula = lm(
    Y ~ X + C, data = df),
  labels = labs,
  imply = TRUE
)

