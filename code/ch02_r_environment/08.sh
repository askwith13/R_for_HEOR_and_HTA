# Extracted from ch02_r_environment.typ, lines 142-152
# Section: == 2.4 Version control with Git and GitHub
# Chapter: 2

git init
git add .
git commit -m "Initial commit: project scaffold and renv lockfile"
git checkout -b scenario/alt-discount-rate
# ... make changes ...
git add R/run_model.R
git commit -m "Add 1.5% discount rate scenario per reviewer request"
git push origin scenario/alt-discount-rate
# open a pull request on GitHub for review before merging
