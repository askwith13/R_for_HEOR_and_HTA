# Extracted from ch02_r_environment.typ, lines 302-324
# Section: == 2.6 Containers (Docker) for reproducible models

FROM rocker/r-ver:4.3.2

# System libraries needed by common HEOR packages
# (XML, curl, and SSL for reporting/network packages;
# a Fortran compiler for survival/optimisation routines)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /model

# Bring in the renv lockfile and restore from it
COPY renv.lock renv.lock
RUN Rscript -e "install.packages('renv'); renv::restore()"

COPY . .

CMD ["Rscript", "run_model.R"]
