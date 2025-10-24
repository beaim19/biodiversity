
# Use the Rocker Shiny base image
FROM rocker/shiny:latest

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*



# Set a working directory for the app (matches Shiny Server default)
WORKDIR /srv/shiny-server/my-app

# Set environment variables so renv behaves consistently
ENV RENV_PATHS_LIBRARY_ROOT=/srv/shiny-server/my-app/renv/library
ENV RENV_PATHS_CACHE=/home/shiny/.cache/R/renv/cache


# Create cache directory for the 'shiny' user
RUN mkdir -p /home/shiny/.cache/R/renv/cache && chown -R shiny:shiny /home/shiny/.cache



#RUN mkdir -p /srv/shiny-server/my-app


# Copy only renv.lock and renv folder first (so this layer can be cached)
COPY renv.lock .
COPY renv/ ./renv/


# Install renv and restore packages
#RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" \
# && R -e "setwd('/srv/shiny-server/my-app'); renv::restore(prompt = FALSE)"



# RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" \
# && R -e "setwd('/srv/shiny-server/my-app'); print(getwd()); list.files(); renv::restore(prompt = FALSE)"

          
# Install renv and restore packages (as shiny user)
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" && \
    su -s /bin/bash shiny -c "R -e \"Sys.setenv(RENV_PATHS_LIBRARY_ROOT='/srv/shiny-server/my-app/renv/library', \
                                         RENV_PATHS_CACHE='/home/shiny/.cache/R/renv/cache'); \
                               renv::load('/srv/shiny-server/my-app'); \
                               renv::restore(prompt = FALSE, clean = TRUE)\""




# THEN copy the rest of the app code
COPY . .

# Ensure correct permissions for Shiny Server
RUN chown -R shiny:shiny /srv/shiny-server

# Expose port (Shiny default)
EXPOSE 3838

# Run Shiny Server
CMD ["/usr/bin/shiny-server"]

