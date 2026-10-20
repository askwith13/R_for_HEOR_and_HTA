# Extracted from ch35_case_studies.typ, lines 335-339
# Section: === Step (e): structural-uncertainty scenarios
# Chapter: 35

fit_os_ll <- flexsurvreg(Surv(os_time, os_event) ~ 1, data = ipd, dist = "llogis")
shape_ll <- fit_os_ll$res["shape", "est"]; scale_ll <- fit_os_ll$res["scale", "est"]
scale_ll_new <- scale_ll * hr_os_nma^(-1 / shape_ll)
