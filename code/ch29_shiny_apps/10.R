# Extracted from ch29_shiny_apps.typ, lines 399-410
# Section: == 29.6 Deployment: shinyapps.io, Posit Connect, Docker, servers
# Chapter: 29

rsconnect::setAccountInfo(
  name   = "your-account",
  token  = "xxxxxxxxxxxxxxxx",
  secret = "yyyyyyyyyyyyyyyy"
)

rsconnect::deployApp(
  appDir  = "tb_model_app",
  appName = "tb-markov-psa-explorer"
)
