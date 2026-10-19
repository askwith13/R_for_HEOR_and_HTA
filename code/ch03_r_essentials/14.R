# Extracted from ch03_r_essentials.typ, lines 320-333
# Section: == 3.5 Performance: profiling, `Rcpp`, parallelisation (`future`, `furrr`)
# Chapter: 3

library(Rcpp)

cppFunction('
  double cycle_sum(NumericVector costs, double discount_rate) {
    double total = 0;
    int n = costs.size();
    for (int i = 0; i < n; i++) {
      total += costs[i] / pow(1 + discount_rate, i);
    }
    return total;
  }
')
