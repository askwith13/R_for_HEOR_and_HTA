# Extracted from ch30_r_packages_pipelines.typ, lines 87-91
# Section: == 30.2 Package structure with `usethis` and `devtools`
# Chapter: 30

devtools::load_all()   # load current source, no install needed
devtools::check()      # full R CMD check: docs, examples, tests, NAMESPACE
devtools::install()    # install locally
