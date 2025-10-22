
library(DBI)
library(duckdb)

read_country_files <- function(list_countries, country_name){

    file_country_name <- paste0(list_countries[[country_name]], '_data.Rds')
    
    if(file.exists(paste0('data/', file_country_name))){
      
      data <- readRDS(paste0('data/', file_country_name))
      
      data[,':='
               (monthYear = lubridate::make_date(year(eventDate),
                                                 month(eventDate)))]
      
      
      
      # Convert to sf for spatial operations
      df_sf <- st_as_sf(data, coords = c("longitudeDecimal", "latitudeDecimal"), 
                        crs = 4326) # Earth centered coordinate
      
      
      # Project to meters (Web Mercator for local clustering)
      df_proj <- st_transform(df_sf, 3857)  # EPSG:3857 => in meters
      
      
      # Extract coordinates for clustering
      coords <- st_coordinates(df_proj)
      
      # Perform DBSCAN clustering (e.g., 1000 meters = 1 km radius)
      # Adjust eps depending on how tight should be the clusters
      db <- dbscan(coords, eps = 1000, minPts = 1)
      
      # Aggregate values by cluster
      data$cluster <- db$cluster

    } else {
      NULL
    }
    
    data[, ':='
         (season = factor(getSeason(eventDate),
                          levels = c('Winter',
                                     'Spring',
                                     'Summer',
                                     'Fall')),
           Year = lubridate::year(eventDate))]
    
 return(data)
  
}

# Multimedia data

con <- dbConnect(duckdb())
onStop(function() dbDisconnect(con, shutdown = TRUE))

get_images <- function(obs_id, limit = 60L){
  
  ph <- paste(rep('?', length(obs_id)), collapse = ", ")
  
  sql <- sprintf("SELECT accessURI
    FROM read_parquet('data/species_images.parquet')
    WHERE CoreId IN (%s)
    LIMIT ?", ph)
  
  DBI::dbGetQuery(
    con,
    sql,
    params = c(as.list(obs_id), as.integer(limit))
  )
}


`%||%` <- function(a, b) if (is.null(a) || !length(a) || !nzchar(a)) b else a
