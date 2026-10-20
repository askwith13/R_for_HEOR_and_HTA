# Extracted from ch35_case_studies.typ, lines 238-256
# Section: === Step (b): projecting the new treatment's curves using the NMA hazard ratio
# Chapter: 35

hr_os_nma  <- 0.68   # NMA-pooled OS hazard ratio, new agent vs comparator
hr_pfs_nma <- 0.74   # NMA-pooled PFS hazard ratio, new agent vs comparator

shape_pfs <- fit_pfs_comp$res["shape", "est"]; scale_pfs_comp <- fit_pfs_comp$res["scale", "est"]
shape_os  <- fit_os_comp$res["shape", "est"];  scale_os_comp  <- fit_os_comp$res["scale", "est"]

scale_pfs_new <- scale_pfs_comp * hr_pfs_nma^(-1 / shape_pfs)
scale_os_new  <- scale_os_comp  * hr_os_nma^(-1 / shape_os)

S_pfs <- function(t, arm) {
  sc <- if (arm == "comp") scale_pfs_comp else scale_pfs_new
  exp(-(t / sc)^shape_pfs)
}
S_os <- function(t, arm) {
  sc <- if (arm == "comp") scale_os_comp else scale_os_new
  exp(-(t / sc)^shape_os)
}
