# Extracted from ch02_r_environment.typ, lines 186-191
# Section: == 2.5 Working with Stan, JAGS and C++ toolchains
# Chapter: 2

install.packages("cmdstanr",
  repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
cmdstanr::check_cmdstan_toolchain()
cmdstanr::install_cmdstan()
