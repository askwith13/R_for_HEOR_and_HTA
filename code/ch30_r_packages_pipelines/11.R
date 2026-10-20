# Extracted from ch30_r_packages_pipelines.typ, lines 262-267
# Section: == 30.6 Sharing models with HTA agencies and reviewers
# Chapter: 30

# Illustrative: creating a package snapshot for a dossier release
usethis::use_version("minor")   # bumps DESCRIPTION version, e.g. 1.1.0 -> 1.2.0
# Then, on GitHub: Releases -> "Draft a new release" -> tag v1.2.0
# -> attach the dossier PDF and the source zip as release assets
