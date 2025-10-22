# Biodiversity
Interactive map and plot of biodiversity around the world


- [Overview](#overview)
- [Installation](#instalation)
- [Reading the data](#dataread)
- [Project Structure](#project-structure)
- [Modules](#modules)
- [Testing](#testing)



# Overview

This Shiny app allows users to see the frequency and quantity of plant and animal species being observed in different countries. 



# Installation

## Clone repository
git clone https://github.com/beaim19/biodiversity.git


## Install dependencies
renv::restore()




# Reading the data

The data was read outside the app and save in Rds format for more efficiency. 
I used the packages DBI and duckDB. DuckDB can connect to different data sources allowing for an optimized and fast query execution.  
In this process, you first create an in-memory database, where con will hold the connection object that is used to send queries to this DuckDB instance. DuckDB can query csv files directly using SQL without needing to import then first, and it auto-detects the columns types of the csv files.


```r
con <- dbConnect(duckdb())
```

Then you send a SQL query to the data base, returning a data frame
```
res <- dbGetQuery(con, "
  SELECT *
  FROM 'occurence.csv'
  WHERE country = 'Poland'
")
```

I saved res (converted to data.table) as an .Rds file. 

There is also a multimedia file with links to pictures. This file is saved as .parquet, and it is read
using SQL and selecting only the data for the selected country and species. 

There is data for 4 countries: Poland, Portugal, Georgia, and Italy. Each country is saved in their .Rds file. The app will read the country file the first time the user selects that country. A message is displayed so the user knows the data is being uploaded. When a country file is read, then the data is saved with reactiveValues so it is available the next time the user selects that country, without the need to upload it again. 

Once the app starts, location coordinates are used to create clusters that will later be used to create a data.table that has the count of locations where the species were seen, and the total number of individuals for each cluster.  


# Project Structure

```r
biodiversity/
├── app.R
├── biodiversity.Rproj
├── data
  ├── PL_data.Rds
  ├── PT_data.Rds
  ├── IT_data.Rds
  ├── GR_data.Rds
  ├── species_images.parquet
├── R
  ├── about_tab.R
  ├── functions.R
  ├── home_tab.R
  ├── mod_dynamic_map.R
  ├── mod_filter_country.R
  ├── mod_filter_obs.R
  ├── mod_filter_species.R
  ├── mod_initial_msg.R
  ├── mod_map.R
  ├── mod_read_data.R
  ├── mod_summary_plots.R
  ├── mod_value_boxes.R
  ├── species_info.R
  ├── theme.R
├── README.md
├── renv
  ├── activate.R
  ├── library
  ├── settings.json
  ├── staging
├── renv.lock
├── test
  ├── testthat
    ├── test_mod_filter_country.R
    ├── test_mod_filter_dates.R
    ├── test_mod_filter_species.R
    ├── test_mod_map.R
    ├── test_read_data_function.R
├── testthat.R
├── www
  ├── _my_styles.scss
  ├── carpintero2.png
  ├── fit-reveal.js
  ├── logoLNG_transparent.png
  ├── modal-str.js
  ├── owl.JPG
  ├── patagonia.jpg
  ├── scss
    ├── _about_tab.R_buttons.scss
    ├── _dropdown.scss
    ├── _images.scss
    ├── _layout.scss
    ├── _map_mssg.scss
    ├── _navegation.scss
    ├── _valueboxes.scss
    ├── _variables.scss
```



# Modules

## Filters


### `mod_filter_country.R`

Allows to select country   
 - UI: `mod_country_input_ui(id)`  
 - Server: `mod_country_input_server(id, data)`  
 
 
### `mod_filter_dates.R`  

Allows to select a range of dates  
 - UI: `mod_dates_ui(id)`  
 - Server: `mod_dates_server(id, data)`  
 
 
### `mod_filter_obs.R`  
 
Allows to select type of counts to see: total times there was an occurence, or the total number of individuals that were count among all the occurrences  
 - UI: `mod_obs_ui(id)`  
 - Server: `mod_obs_server(id)`  
 
 
### `mod_filter_species.R`  

Allows to select the species to visualize using vernacular or scientific name. It updates with the selection of the country  
 - UI: `mod_species_ui(id)`  
 - Server: `mod_species_server(id, data)`  
 
 
## Outputs  


### `mod_map.R`  

Shows a map with the occurrence of the selected species in that date range. Circles indicate the occurrence and the size of the circle and label within it indicates the number of occurrences or individuals recorded in that cluster. 
The argument `map_type` allows to show an empty map with a message when the selected date range does not include any occurrence for that species. 
The arguments `species_name` and `observationType` refer to the species selected and the type of observation, selected in their modules.   
 - UI: `mod_map_ui(id)`  
 - Server: `mod_map_server(id, mydata, map_type, species_name = NULL, observationType = NULL)`  


### `mod_value_boxes.R`  

Shows the values for the data selected and the number of occurrences. 
The argument `picture` is not needed for now in any of the boxes.   
 - UI: `mod_valuebox_ui(id)`  
 - Server: `mod_valuebox_server(id, title, value_to_show, icon_to_show = NULL, picture = NULL)`  
 
 
## Read Data

### `mod_read_data.R`

This file has the function that would read the data for the first time based on the selection of the country.
 
 
# Testing

Used `testthat` and `testServer()` for unit tests of Shiny modules. 

To run the test:
```r
testthat::test_dir("test/testthat")
```


 
