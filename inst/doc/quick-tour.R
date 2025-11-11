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

## ----dotwhisker, eval=has_dotwhisker, warning=FALSE, fig.width=7--------------
DAGassist(dag = dag_model,
          formula = lm(Y ~ X + M + Z + A, data = df),
          type = "dotwhisker")

