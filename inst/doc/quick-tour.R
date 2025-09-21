## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(DAGassist)
# load helper libraries
library(modelsummary)
library(dagitty)

## ----sample-------------------------------------------------------------------
n <- 500
Z <- rnorm(n)
A <- rnorm(n)
X <- 0.6*Z + rnorm(n)
M <- 0.5*X + 0.3*Z + rnorm(n)
Y <- 1.0*X + 0.0*M + 0.5*Z + rnorm(n)
df <- data.frame(Y, X, M, Z, A)

dag_model <- dagitty('
  dag {
    Z -> X
    Z -> Y
    A -> Y
    X -> M
    X -> Y
    M -> Y
    X [exposure]
    Y [outcome]
  }')

## ----console-report-----------------------------------------------------------

DAGassist(
  dag = dag_model,
  formula = lm(Y ~ X + M + Z + A, data = df)
)

## ----report-------------------------------------------------------------------
#initialize a temporary path
out_tex <- file.path(tempdir(), "dagassist_report.tex")

DAGassist(
  dag = dag_model,
  formula = lm(Y ~ X + M + Z + A, data = df),
  type = "latex", 
  out = out_tex) #put your output directory and file name here

cat(readLines(out_tex, n = 15), sep = "\n") # briefly show the output

