# Extracted from ch22_des_dynamic_models.typ, lines 217-237
# Section: === Compartmental models (SIR/SEIR) with `deSolve`
# Chapter: 22

library(deSolve)

sir_model <- function(t, y, parms) {
  S <- y["S"]; I <- y["I"]; R <- y["R"]
  with(as.list(parms), {
    N  <- S + I + R
    dS <- -beta * S * I / N
    dI <-  beta * S * I / N - gamma * I
    dR <-  gamma * I
    list(c(dS, dI, dR))
  })
}

N0     <- 10000
y0     <- c(S = N0 - 1, I = 1, R = 0)
parms  <- c(beta = 0.4, gamma = 0.2)          # R0 = beta / gamma = 2
times  <- seq(0, 180, by = 1)

out <- as.data.frame(ode(y = y0, times = times, func = sir_model, parms = parms))
