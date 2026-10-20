# Extracted from ch29_shiny_apps.typ, lines 420-432
# Section: == 29.6 Deployment: shinyapps.io, Posit Connect, Docker, servers

# Illustrative only -- verify exact base image and package list for your setup
FROM rocker/shiny:4.3.2

RUN install2.r --error \
    shiny ggplot2 dplyr quarto rsconnect RSQLite

COPY ./tb_model_app /srv/shiny-server/tb_model_app

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
