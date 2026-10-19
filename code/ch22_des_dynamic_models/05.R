# Extracted from ch22_des_dynamic_models.typ, lines 303-332
# Section: == 22.6 Worked example: a TB screening/preventive-therapy intervention model
# Chapter: 22

library(deSolve)

seir_model <- function(t, y, parms) {
  S <- y["S"]; E <- y["E"]; I <- y["I"]; R <- y["R"]
  with(as.list(parms), {
    N <- S + E + I + R
    force_inf <- beta * I / N * (1 - ve)
    dS <- -force_inf * S
    dE <-  force_inf * S - sigma * E
    dI <-  sigma * E - gamma * I
    dR <-  gamma * I
    list(c(dS, dE, dI, dR))
  })
}

N0    <- 100000
y0    <- c(S = N0 - 50, E = 0, I = 50, R = 0)
times <- seq(0, 10, by = 1 / 52)          # 10-year horizon, weekly steps

base_parms <- c(beta = 2.0, sigma = 1, gamma = 1, ve = 0)    # no programme, R0 = 2
int_parms  <- c(beta = 2.0, sigma = 1, gamma = 1, ve = 0.3)  # programme: 30% effective protection

out_base <- as.data.frame(ode(y0, times, seir_model, base_parms))
out_int  <- as.data.frame(ode(y0, times, seir_model, int_parms))

cum_base <- tail(out_base$I + out_base$R, 1)   # cumulative ever-infected-or-infectious, per 100,000
cum_int  <- tail(out_int$I  + out_int$R,  1)
cases_averted <- cum_base - cum_int
