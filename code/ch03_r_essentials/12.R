# Extracted from ch03_r_essentials.typ, lines 301-314
# Section: == 3.4 Writing functions, parameter lists and defensive programming
# Chapter: 3

validate_probability <- function(p, name) {
  if (!is.numeric(p)) {
    stop(sprintf("'%s' must be numeric, got %s.", name, class(p)[1]))
  }
  if (p < 0 || p > 1) {
    stop(sprintf("'%s' must lie in [0, 1], got %s.", name, p))
  }
  if (p > 0.9) {
    warning(sprintf("'%s' = %s is unusually high; check the source.", name, p))
  }
  invisible(p)
}
