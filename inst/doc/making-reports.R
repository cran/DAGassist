## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----install, eval=FALSE------------------------------------------------------
# install.packages("pak")
# pak::pak("grahamgoff/DAGassist")

## ----helpers------------------------------------------------------------------
#load DAGassist
library(DAGassist) 
#load libraries to help export
library(modelsummary)
library(writexl)
library(knitr)
library(rmarkdown)

## ----dag, echo=FALSE, warning=FALSE, message=FALSE, fig.width=8, fig.height=4, dpi=150, out.width="100%", fig.alt="Example DAG"----
library(ggdag)
library(dagitty)
library(tidyverse)

# X axis positions for DAG
x_pos <- c(
  "B" = 0,
  "A" = 0,
  "C" = 0,
  "F" = 1,
  "D" = 1,
  "H" = 1,
  "Y" = 2,
  "G" = 2
)

# Y axis positions for DAG
y_pos <- c(
  "A" = 1,
  "F" = 1,
  "G" = 1,
  "B" = 0,
  "D" = 0,
  "Y" = 0,
  "C" = -1,
  "H" = -1
)

# Define the DAG with custom coordinates
dag_model <- dagify(
  Y ~ D + F + H + G,
  D~ A + B + C,
  H ~ C,
  A ~ F + B,
  exposure = "D",
  outcome  = "Y",
    
  coords = list(x = x_pos, y = y_pos)
              
)

ggdag_status(dag_model,
             text = TRUE) +
  theme_dag() +
  scale_fill_manual(             
    values = c(
      exposure = "black",
      outcome  = "grey30",
      none     = "grey90"
    )
  ) +
  scale_color_manual(
    values = c(
      exposure = "black",
      outcome  = "grey30",
      none     = "grey60"
    )
  ) +
  theme(legend.position = "none") 
############################# make test data ##############################
set.seed(123)
n <- 1000

# exogenous variables 
B <- rnorm(n, 0, 1)
C <- rnorm(n, 0, 1)
F <- rnorm(n, 0, 1)
G <- rnorm(n, 0, 1)

# endogenous variables
A <- 0.6*F + 0.5*B + rnorm(n, 0, 1) # A ~ F + B
H <- 0.8*C + rnorm(n, 0, 1) # H ~ C
D <- 0.9*A + 0.5*B + 0.4*C + rnorm(n, 0, 1) # D ~ A + B + C
Y <- 1.0*D + 0.6*F + 0.5*H + 0.4*G + rnorm(n, 0, 1) # Y ~ D + F + H + G

df <- data.frame(Y, D, H, A, G, F, C, B)


## ----head---------------------------------------------------------------------
head(df)

## ----main-model---------------------------------------------------------------
original <- lm(Y ~ D + G + H + F + A + B + C, data = df)

## ----report-path, include=FALSE-----------------------------------------------
out_tex <- file.path(tempdir(), "dagassist_report.tex")
out_docx <- file.path(tempdir(), "dagassist_report.docx")
out_xlsx <- file.path(tempdir(), "dagassist_report.xlsx")
out_txt  <- file.path(tempdir(), "dagassist_report.txt")

## ----report, results='asis'---------------------------------------------------
DAGassist(dag = dag_model, #specify a dagitty or ggdag object
          formula = lm(Y ~ D + G + H + F + A + B + C, data = df), #provide your formula
          type = "text", #output type
          out = out_txt) #a temporary directory, for the purpose of this vignette

cat(readLines(out_txt), sep = "\n") # show the output

