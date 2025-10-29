
###############################################
# Stage 1: Build stage - install R packages
###############################################
FROM rocker/r-ver:4.4.1 AS build

# System dependencies for common R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    cmake \
    make \
    build-essential \
    gdal-bin \
    && apt-get clean && rm -rf /var/lib/apt/lists/*



# Set a working directory for the app (matches Shiny Server default)
WORKDIR /build

# Copy only renv.lock and renv folder first (so this layer can be cached)
COPY renv.lock .
COPY renv/ ./renv/

# Install renv (as root)
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" \
 && R -e "renv::restore(prompt = FALSE)"
 
 
###############################################
# Stage 2: Runtime stage - Shiny Server
###############################################
FROM rocker/shiny:4.4.1

# important here ggtext-base
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    cmake \
    make \
    build-essential \
    gdal-bin \
    gettext-base \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
COPY --from=build /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Copy your entire Shiny app (not just app.R)
WORKDIR /srv/shiny-server/
COPY . /srv/shiny-server/

# Copy configuration
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf


# Create directories and fix permissions
RUN mkdir -p /var/lib/shiny-server/bookmarks/shiny && \
    chown -R shiny:shiny /var/lib/shiny-server /srv/shiny-server /etc/shiny-server


USER shiny

ENV RENV_ACTIVATE_PROJECT=false
ENV PORT=8080
EXPOSE 8080



CMD ["/bin/bash", "-c", "envsubst < /etc/shiny-server/shiny-server.conf > /tmp/shiny.conf && exec /usr/bin/shiny-server /tmp/shiny.conf"]



