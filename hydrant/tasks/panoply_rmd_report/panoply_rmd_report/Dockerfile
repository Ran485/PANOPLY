FROM broadcptacdev/panoply_common:latest

LABEL maintainer="proteogenomics@broadinstitute.org"
LABEL description="Docker for generating Rmarkdown reports for different Panoply modules."

ENV wd /home/pgdac/

COPY . $wd
WORKDIR $wd


RUN apt-get update
RUN apt-get -t unstable install -y libxml2-dev  # required for R-package 'XML'
RUN apt-get -t unstable install -y pandoc  # rmarkdown
RUN apt-get -t unstable install -y libfontconfig1-dev  # font config library for R-package kableExtra

## ssl (already installed in panoply_libs)
# RUN apt-get install -y libssl-dev
## libcurl (already installed in panoply_libs)
# RUN apt-get install -y libcurl4-openssl-dev

## install R-packages
# cmapR already installed in panoply_libs
# RUN R -e "devtools::install_github('cmap/cmapR')"
RUN R -e "library(pacman);p_install('devtools')"
RUN R -e "devtools::install_github('cmap/morpheus.R')"
RUN R -e "library(pacman);p_install('gtools')"
RUN R -e "library(pacman);p_install('rmarkdown')"
RUN R -e "library(pacman);p_install('WriteXLS')"
RUN R -e "library(pacman);p_install('shiny')"
RUN R -e "library(pacman);p_install('plotly')"
RUN R -e "library(pacman);p_install('seriation')"
RUN R -e "library(pacman);p_install('kableExtra')"


## install missing fonts and images required for morpheus
# RUN mv fonts/* /usr/local/lib/R/site-library/morpheus/htmlwidgets/lib/css/fonts/
# RUN mv images/* /usr/local/lib/R/site-library/morpheus/htmlwidgets/lib/css/images/
# RUN rm -R fonts
# RUN rm -R images
