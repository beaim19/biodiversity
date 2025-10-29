# -------------------------------------------------------------
# R project startup configuration
# -------------------------------------------------------------

# Always use a fixed CRAN mirror for reproducibility
options(repos = c(CRAN = "https://cloud.r-project.org"))

# -------------------------------------------------------------
# renv activation control
# -------------------------------------------------------------
# When running locally (interactively in RStudio, etc.),
# enable renv to ensure reproducible environments.
# When running in Docker / Cloud Run, disable it.

if (interactive() && file.exists("renv/activate.R")) {
  message("→ Activating renv for local development.")
  source("renv/activate.R")
} else {
  message("→ Running in Docker / production: renv disabled.")
  Sys.setenv(RENV_ACTIVATE_PROJECT = "false")
}
