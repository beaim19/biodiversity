


library(shiny)
library(shinydashboard)
library(shinydisconnect)
library(data.table)
library(openxlsx)
library(DT)
library(ggplot2)
library(plotly)
library(dplyr)
library(shinyWidgets)
library(leaflet)
library(htmltools)
library(sf)
library(dbscan)
library(bslib)
library(sass)
library(shinyjs)
library(ggrepel)

#options(shiny.reactlog = TRUE)
#options(shiny.launch.browser = TRUE)
# options(shiny.sanitize.errors = FALSE)

source('R/mod_value_boxes.R')
source('R/mod_map.R')
source('R/mod_filter_country.R')
source('R/mod_filter_species.R')
source('R/mod_filter_obs.R')
source('R/mod_read_data.R')
source('R/theme.R')
source('R/home_tab.R')
source('R/about_tab.R')




list_country_files <- list('Portugal' = 'PT',
                           'Italy' = 'IT',
                           'Georgia' = 'GR',
                           'Poland' = 'PL'
)

theme <- make_theme()

# 1 - UI =======================================================================

ui <- bslib::page_navbar(

  
  header = ({
    tags$head(singleton(tags$script(src = 'fit-reveal.js')), # in www
              tags$script(src = 'leaflet-bounds.js'), # in www
     
              disconnectMessage(
                text = "You got disconnected. Please click Refresh, or open the App in a new window.",
                refresh = "Refresh",
                background = "#FFFFFF",
                colour = "#444444",
                refreshColour = "#478851ff",
                overlayColour = "#000000",
                overlayOpacity = 0.6,
                width = 450,
                top = 50,
                size = 22,
                css = ""
              )
              )
    
    
    }),

  
  id = 'main_tabs',
  
  lang = 'en',
  
  title = tags$div(class = 'logo-container',
                   a(tags$img(src="logoLNG_transparent.png", class = 'logo'),
                     href="https://www.getsupernal.ai///", target = "_blank")),
  
  theme = theme,
  
  window_title = 'Datatraveller',
  
  
  # Home tab ----
  
  bslib::nav_panel(
    
    title = 'Home',
    
    layout_columns(
      
      col_widths = c(6, 6),
      
      # left column
      text_home(), # R/home_tab

      # right column
      img_home() # R/home_tab
      
    )
    
  ),
  
  # Map tab ----
  bslib::nav_panel(

    title = 'Map',
    
    # __ sidebar ----
    layout_sidebar(
      
      sidebar = sidebar(
        
        position = 'left',
        
        id = 'my_sidebar',
        
        open = 'open',
        
        mod_country_input_ui('checkcountry'), # R/mod_filter_country
        br(),
        
        mod_species_ui('checkname'), # R/mod_filter_species
        br(),
        
        # mod_obs_ui('checktypeobs'), # R/mod_filter_obs
        # br(),
        
        ui_map_sidebar('themap')
        
      ),
      
      
      # __ body ----
      layout_column_wrap(
        
        width = 1/5,
        fill = TRUE,
        
        # Country box
        mod_valuebox_ui('country1'), # R/mod_value_boxes
        
        # Vernacular name box
        mod_valuebox_ui('vernacular1'), # R/mod_value_boxes
        
        # Scientific Name
        mod_valuebox_ui('scientific1'), # R/mod_value_boxes
        
        # Number of Observations
        mod_valuebox_ui('observations1'), # R/mod_value_boxes
        
        # Number of individual Counts
        mod_valuebox_ui('individuals1') # R/mod_value_boxes
        
      ),
      
      mapUI('themap')
 
    )
  ), # nav_panel
  
  

  
  # Summary tab ----
  bslib::nav_panel(
    
    title = 'Summary Plots',
    
    # sidebar ----
    layout_sidebar(
      
      sidebar = sidebar(
      position = 'left',
      
      id = 'summary_sidebar',
      
      open = 'open',
      
    
      mod_country_input_ui('checkcountry2'), # R/mod_filter_country
      br(),
      
      mod_dates_ui('dates_slider')
      
      ),
      
      # body ----
      ui_plots_summary('summary_plots')

    )
    
  ),
  
  bslib::nav_spacer(),
  
  # About tab ----
  bslib::nav_menu(
    
    title = 'About',
    
    bslib::nav_panel(
      
      title = 'Reading the map',
      
      layout_columns(
        
        col_widths = c(6, 6),
        
        # left column
        text_about(), # R/text_about
        
        # right column
        img_about() # R/home_tab
        
      )
    ), 
    
    bslib::nav_panel(
      
      title = 'About us',
      
      layout_columns(
        
        
        col_widths = c(6, 6),
        
        # left column
        text_about_us(), # R/text_about
        
        # right column
        img_about_us() # R/home_tab
        
      )
      
    )
    
    
    
  ),
  
  # Footer ----
  footer = ({

    div(
    style = "padding: 1rem; text-align: center; background-color: #f8f9fa;",
    "© 2025 Datatraveller"
    )

    
  })
) # page_navbar






# 2 - SERVER ===================================================================

server <- shinyServer(function(input, output, session){
  
  
  # map tab active to get map ready if in another tab
  active_tab <- reactive(input$main_tabs)

  is_map_tab <- reactive(active_tab() == 'Map')
  
  last_bounds <- reactiveVal(NULL)
  
  #shinyjs::logjs('hello')
  
  # dates slider
  minYear <- reactiveVal(NULL)
  maxYear <- reactiveVal(NULL)
  
  observe({
    req(selected_dates())
    minYear(year(selected_dates()[1]))
    maxYear(year(selected_dates()[2]))
  })
  
  
  # Filter selections map tab ----
  selected_country <- mod_country_input_server('checkcountry', list_country_files, latest_country) #R/mod_filter_country
  selected_species <- mod_species_server('checkname', data_country) #R/mod_filter_species

  # Filter selection summary tab ----
  selected_dates <- mod_dates_server('dates_slider', data_country, minYear = minYear, maxYear = maxYear) # R/mod_filter_dates
  selected_country2 <- mod_country_input_server('checkcountry2', list_country_files, latest_country) #R/mod_filter_country


  # latest country ----
  latest_country <- reactiveVal(NULL)

  
  observe({
    req(selected_country())
    latest_country(selected_country())
  }) %>% bindEvent(selected_country(), ignoreInit = TRUE)
  
  observe({
    req(selected_country2())
    latest_country(selected_country2())
  }) %>% bindEvent(selected_country2(), ignoreInit = TRUE)
  
  
  
  # Data read -----
  # save the data of countries already selected for efficiency when coming back
  # to a country that has already been seen
  
  cached_data <- reactiveValues() # to store the data of countries already uploaded

  
  # _getting the data ----
  
  observeEvent(c(latest_country()),{

    req(latest_country())
    # req(selected_country())
    # country <- selected_country()
    country <- latest_country()
    
    
    if(!is.null(cached_data[[country]])){ # data already uploaded
      
      message('Using cached data for ', country)

      
    } else { # data needs to be read from file
      
      showModal(modalDialog(
        title = "Please wait a few seconds",
        paste0("Loading data for ", country),
        easyClose = FALSE,
        footer = NULL
      ))
      
      message('Reading data for ', country)
      
      new_data <- read_country_files(list_country_files,
                                     country_name = country) # R/mod_read_data
      
      cached_data[[country]] <- new_data
      
      removeModal()
    }
    
  })
  
  
  # Outputs no module ----------------------------------------------------------
  
  # _Initial message ----
  after_initial <- reactiveVal(FALSE)
  
  observeEvent(c(latest_country()), {

    after_initial(TRUE)
    
  })
  

  

  # Reactive data --------------------------------------------------------------
  

  # _data country ----
  
  data_country <- reactive({
    
    req(latest_country())
    
    cached_data[[latest_country()]]
    
  })
  

  
  # _data_species ----
  data_names <- reactive({
    
    req(data_country())
    req(selected_species())
    
    sel_sp <- selected_species()
    
    dt <- data_country()[(vernacularName %in% sel_sp | scientificName %in% sel_sp)]
    
    setorder(dt, eventDate)
    
    dt
    
  })
  
  
 
  
  
  # _data slider filter ----
  data_rc <- reactive({

    req(selected_dates())
    req(nrow(data_country()) > 0)
    
    data_country()[eventDate >= selected_dates()[1]
                   & eventDate <= selected_dates()[2]]
    
  })
  
  # _data for plot ----
  data_plot <- reactive({
    
    req(selected_country())
    req(selected_species())

    
    subdata_agg <- data_names()[,
                             .(Nn = .N,
                               totalCount = sum(individualCount)),
                             by = .(cluster, monthYear, country, vernacularName, scientificName)]
    
    subdata_agg2 <- subdata_agg[,
                                .(N = .N,
                                  totalCount = sum(totalCount)),
                                by = .(monthYear, country, vernacularName, scientificName)]
    
    
  })
  
  
  
  
  # _ data for map ----
  data_map <- reactive({

    req(data_names())
    
    for_map <- copy(data_names())
    
    for_map[,':='
            (newLat = mean(latitudeDecimal),
              newLng = mean(longitudeDecimal)),
            by = .(cluster)]
    
    agg_df <- for_map[,
                      .(totalCount = sum(individualCount),
                        lat = mean(newLat),
                        lng = mean(newLng)),
                      by = .(cluster, country, vernacularName, scientificName, monthYear)]
    
    agg_df[,
           N := length(unique(cluster)),
           by = .(country, vernacularName, scientificName)]
    
    agg_df[,':='
           (Ncluster = .N,
             N = N),
           by = .(cluster, country, vernacularName, scientificName)]
    
    agg_df2 <- unique(agg_df[,
                             .(N = N,
                               Ncluster = Ncluster,
                               lat = mean(lat), # to save minimal differences
                               lng = mean(lng),
                               totalCount = sum(totalCount)),
                             by = .(cluster, country, vernacularName, scientificName)])
    
  })
  
  
  # Outputs modules ------------------------------------------------------------
  
  # _value Boxes ----
  
  observeEvent(selected_country(), {
    
    if (selected_country() ==''){

      mod_valuebox_server('country1', 'Country', 'Select Country') 
      
    } else{

      mod_valuebox_server('country1', 'Country', selected_country())
    }
    
  })
  
  
  
  observeEvent(c(selected_country(), selected_species()), { 
    
    if (selected_species() %in% c('', 'Select Species') || selected_country() == ''){
      
      sp_msg_v <- 'Select Species'
      sp_msg_sc <- 'Select Species'
      co_sp_msg_l <- 'Select Country and Species'
      co_sp_msg_tc <- 'Select Country and Species'

      
    } else {
      
      req(data_map())
      req(data_plot())
      
      sp_msg_v <- data_names()$vernacularName[1]
      sp_msg_sc <- data_names()$scientificName[1]
      co_sp_msg_l <- nrow(data_map())
      co_sp_msg_tc <- sum(data_plot()$totalCount)

    }
    
    
   
    mod_valuebox_server('scientific1', 'Scientific Name', sp_msg_sc)
    
    mod_valuebox_server('vernacular1', 'Vernacular Name', sp_msg_v) #'paw'
    
    mod_valuebox_server('observations1', 'Total Locations', co_sp_msg_l) #'location-pin'
    mod_valuebox_server('individuals1', 'Total Individual Count', co_sp_msg_tc) # 'dice-five'

     })

  
  # _Map ----
  
  map_server("themap", 
              data_country = data_country,  
              data_map = data_map, 
              data_names = data_names,
              after_initial = after_initial,
              species = selected_species,
              latest_country = latest_country,
              is_visible_tab = is_map_tab)
  
  outputOptions(output, 'themap-map', suspendWhenHidden = FALSE)

  
  # _Summary plots ----
  server_plot_summary('summary_plots', 
                      data_rc, 
                      minYear = minYear, 
                      maxYear = maxYear,
                      latest_country = latest_country,
                      after_initial = after_initial,
                      datessel = selected_dates
                      )
  
 
  
  
}) # server



# 3 - RUN APP ==================================================================
shinyApp(ui = ui, server = server)



