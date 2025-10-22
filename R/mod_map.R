
# UI ----
ui_map_sidebar <- function(id){
  ns <- NS(id)
  uiOutput(ns('sidebar'))
}


mapUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(id = 'map-wrap',
        uiOutput(ns('btn_panel')),
        leafletOutput(ns("map"), height = '80vh'),
        div(id = ns('btn_species'), class = 'map_btn_sp',
            actionButton(ns('species_info'), 'Info species', class = 'btn btn-primary btn-sm')),
        div(id = ns('overlay'), class = 'overlay',
            uiOutput(ns('overlay_body')))
        
    )
    
  )
  
}



# Server ----
map_server <- function(id, 
                       data_country, 
                       data_map, 
                       data_names, 
                       after_initial, 
                       species,
                       latest_country,
                       #selected_country2,
                       is_visible_tab){
  
  
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
    
    last_bounds <- reactiveVal(NULL)
    
    compute_bounds <- function(dt){
      
      if(!nrow(dt)) return(NULL)
      
      list(west = min(dt$longitudeDecimal, na.rm = TRUE),
           south = min(dt$latitudeDecimal, na.rm = TRUE),
           east = max(dt$longitudeDecimal, na.rm = TRUE),
           north = max(dt$latitudeDecimal, na.rm = TRUE))
    }
    

    # State of map ----
    mode <- reactiveVal('static') # static map/dynamic map
    ready <- reactive({
      isTRUE(nzchar(latest_country() %||% '')) && isTRUE(nzchar(species() %||% '')) && isTRUE(species() != 'Select Species')
    })
    
    # Initiate the map ----
    output$map <- renderLeaflet({

      leaflet() |> 
        addTiles() |>
        setView(lng = 0, lat = 20, zoom = 2) 
      
    })
    

    
    # Map play rv ----
    rv <- reactiveValues(
      playing = FALSE,
      idx = 0L
    )
    
    
    # Added sidebar ----
    output$sidebar <- renderUI({
      
      if(!ready()) return(NULL)
      
      if (mode() == 'static'){
        
        div(
          mod_obs_ui(ns('checktypeobs')),
          br(),
          actionBttn(ns('enter_player'),
                     'Click to see dynamic map',
                     style = 'bordered',
                     class = 'my_btn')
        )
        
      } else {
        
        tagList(
          actionBttn(ns('exit_player'),
                     'Back to Static Map',
                     style = 'bordered',
                     class = 'my_btn'),
          sliderInput(ns('speed'),
                         'Speed (ms per step)',
                         min = 150,
                         max = 2000,
                         value = 700,
                         step = 50,
                         width = '100%')
        )
        
      }
      
    })
    
    observationType <- mod_obs_server('checktypeobs') # R/mod_filter_obs
    
    
    
    # Start/Stop/Reset buttons ----
    output$btn_panel <- renderUI({
      
      if (mode() != 'player' || !ready()) return(NULL)
      
      tagList(
        div(class = 'box-controlers',
        actionBttn(inputId = ns('start_btn'),
                   label = 'Start',
                   style = 'bordered',
                   class = 'my_btn'),
        
        actionBttn(inputId = ns('stop_btn'),
                   label = 'Stop',
                   style = 'bordered',
                   class = 'my_btn'),
        
        actionBttn(inputId = ns('reset_btn'),
                   label = 'Reset',
                   style = 'bordered',
                   class = 'my_btn'),
        
        uiOutput(class = 'panel-date',
                 ns('date_info'), inline = TRUE)
        )
      )

    })
    
    
    # clicking dynamic ----
    observeEvent(input$enter_player, {
      
      req(nrow(data_names()) > 0)
      
      mode('player')
      rv$playing <- FALSE
      rv$idx <- 0L
      
      sp_data <- data_names()
      country_dt <- data_country()
      
      bb <- compute_bounds(country_dt)
      
      last_bounds(bb)

      if (nrow(sp_data)){
        leafletProxy(ns('map')) |>
          clearGroup('sightings') |>
          clearGroup('static') |>
          clearGroup('seq') |>
          clearMarkers() |>
          clearShapes() |>
          clearControls() |>
          fitBounds(bb$west, bb$south, bb$east, bb$north)

      }
      
    })
    
    
    
    # clicking static ----
    observeEvent(input$exit_player, {
      
      mode('static')
      rv$playing <- FALSE
      rv$idx <- 0L
      draw_static()
      
    })
    
    
    # if country or species gets updated ----
    observeEvent(c(species(), observationType(), 
                   input$enter_player, latest_country()), { 
      

      req(nrow(data_country()) > 0)
      req(latest_country())

      bb <- compute_bounds(data_names())
      last_bounds(bb)
      
      rv$playing <- FALSE
      rv$idx <- 0L
      
      proxy <- leafletProxy(ns('map'), data = row) |>
        clearGroup('seq') |>
        clearGroup('sightings') |>
        clearControls() |>
        clearShapes()
      
      if (mode() == 'static' || species() %in% c('', 'Select Species') || !nrow(data_names())) draw_static() else{
        
        country <- latest_country() 
        sp <- species()
        sp_data <- data_names()
        country_dt <- data_country()
        
        bb <- compute_bounds(sp_data)

        last_bounds(bb)
        

        proxy |>
          clearGroup('seq') |>
          clearGroup('sightings') |>
          clearControls() |>
          clearMarkers() |>
          clearShapes()
        
        if (nrow(sp_data) > 0){
        
          proxy |>
            fitBounds(bb$west, bb$south, bb$east, bb$north)
           
          
        } else {
          
          proxy |>
            addControl(html = div(class = 'hud',
                                  "No observations for this species"),
                       position = 'topright')
        }
        
      }
      
    }, ignoreInit = TRUE)
    
    
    
    # static map function ----
    draw_static <- function(){

      req(nrow(data_country()) > 0)
      req(latest_country())
      country_dt <- data_country()


      if (species() %in% c('','Select Species')){


        proxy <- leafletProxy(ns('map')) |>
          clearGroup('sightings') |>
          clearMarkers() |>
          clearShapes() |>
          clearControls() 
        
        bb <- compute_bounds(country_dt)
        
        last_bounds(bb)

        proxy <- proxy |>  fitBounds(bb$west, bb$south, bb$east, bb$north) 
        
        
      } else {
        
        proxy <- leafletProxy(ns('map')) |>
          clearGroup('sightings') |>
          clearMarkers() |>
          clearShapes() |>
          clearControls() 
        
        req(species())
        req(nrow(data_map()) > 0)
        data_m <- data_map()
        species_name <- species()
        
        
        if (nrow(data_m) == 1){
          
          bb <- compute_bounds(country_dt)

        } else{
          
          lng1 = min(data_m$lng, na.rm = TRUE)
          lat1 = min(data_m$lat, na.rm = TRUE)
          lng2 = max(data_m$lng, na.rm = TRUE)
          lat2 = max(data_m$lat, na.rm = TRUE)
          
          bb <- list(west = lng1, 
                     south = lat1, 
                     east = lng2, 
                     north = lat2)

        }
        
        last_bounds(bb)
        
        if (is.null(observationType()) || observationType() == 'Unique Observations'){
          
          dark_color <- 'darkorange'
          light_color <- 'yellow'
          varT <- 'N'
          varT2 <- 'Ncluster'
          
          if (max(data_m[['N']]) > 20){multip <- 500} else if(max(data_m[['N']]) > 10){multip <- 1000}else {multip <- 2000}
          
        } else{
          
          dark_color <- 'darkgreen'
          light_color <- 'lightgreen'
          varT <- 'totalCount'
          varT2 <- 'totalCount'
          popup_mssg <- 
            
            if (max(data_m[['totalCount']]) > 40){multip <- 400
            } else if(max(data_m[['totalCount']]) > 20){multip <- 700
            } else if(max(data_m[['totalCount']]) >= 5 | max(data_m[['N']]) > 10){multip <- 1000
            } else if(max(data_m[['totalCount']]) >= 5 | max(data_m[['N']]) > 5){multip <- 3000
            } else {multip <- 6000}
        }
        
          proxy |>
          clearControls() |>
          clearGroup('sightings') |>
          clearMarkers() |>
          clearShapes() |>
          addCircles(
            data = data_m,
            lng = ~lng,
            lat = ~lat,
            radius = ~sqrt(get(varT))*multip,
            color = dark_color,
            fillColor = light_color,
            fillOpacity = 0.5,
            popup = ~sprintf('%s seen here in %i different occasions<br>
                            Total individual counts: %i', species_name, Ncluster, totalCount),
            label = ~as.character(get(varT2)),
            labelOptions = labelOptions(
              noHide = TRUE,
              direction = "center",
              textOnly = TRUE,
              style = list(
                "font-weight" = "bold",
                "font-size" = "14px",
                "color" = "black"
              ))
          )
        
        proxy |> fitBounds(bb$west, bb$south, bb$east, bb$north) 
        
      }
      
      return(proxy)
      
    }
    

    
    # Initial message ----
    output$overlay_body <- renderUI({
      
      if (!after_initial()){
        
        tagList(
          tags$style('#map, .leaflet-control-container {display: none !important;'),
          div(class = 'starting-message',
              icon("circle-info", class = "fa-2x"), 
              br(),
              HTML(paste0('Please select a country and a species<br>by their Vernacular or Scientific Name<br>',
                          'to see how many times it was<br>observed and where<br>
                  <p style="font-size: 40px; color:#478851ff;">Start Exploring!</p>'))
          )
        )
        
      } else {
        NULL
      }
    })
    
    
    
    observeEvent(c(latest_country()),{ 

      req(latest_country())
      country_dt <- data_country()

      bounds <- compute_bounds(country_dt)

      last_bounds(bounds)
      

      session$onFlushed(function(){

        session$sendCustomMessage('fit-and-reveal', c(list(
          id = ns('map'),
          overlayId = ns('overlay'),
          timeout = 800
        ), bounds))

      }, once = TRUE)


    }, ignoreInit = TRUE)
    
    
    
    # Button sp info ----
    observeEvent(input$species_info, {
      
      sc_sp <- data_map()$scientificName[1]
      
      if (species() %in% c('','Select Species')){
        
        removeModal()
        
        showModal(modalDialog(
          title = 'Please Select a Species',
          easyClose = TRUE,
          footer = modalButton("Close")
        )) 

      } else {
        
        removeModal()
        showModal(
          modalDialog(
            title = paste0('About ', species()),
            size = 'xl',
            tryCatch({
              api <-  paste0('https://en.wikipedia.org/api/rest_v1/page/summary/',
                             URLencode(sc_sp, reserved = TRUE))
              txt <- jsonlite::fromJSON(api)$extract
              tagList(
                div(p(txt)),
                div(class = 'new-gallery',
                    uiOutput(ns('gallery'), style = 'height: 100%;')),
                tags$script(src = 'modal-str.js')
              )
            }, error = function(e){
              div(em("No summary found"))
            }),
            easyClose = TRUE,
            footer = modalButton("Close")
          ))
        
        
        # Img gallery ----
        output$gallery <- renderUI({
       
          req(species())
          imgs <- get_images(obs_id = data_names()$id)
          
          urls <- imgs$accessURI
          
          if (!nrow(imgs)) return(tags$em('No images available'))
          tagList(
            div(class = 'gallery_grid',
                lapply(urls, function(u){

                  tags$iframe(
                    src = u, 
                    style = 'width: 100%; height: 90vh; border-radius: 8px;',
                    loading = 'lazy',
                    scrolling = 'no',
                    frameborder = '0',
                    class = 'img-frame'
                  )
                })
                
            )
          )
          
        })
        
      }

    })
    
    
    # Click start btn ----
    observeEvent(input$start_btn,{
      
      leafletProxy(ns('map'), data = row) |>
        clearGroup('seq') |>
        clearControls()
      
      sp_data <- data_names()
      req(nrow(sp_data) > 0)
      rv$playing <- TRUE
      if (rv$idx <= 0L || rv$idx >= nrow(sp_data)) rv$idx <- 0L
      
    })
    
    
    # Click stop btn ----
    observeEvent(input$stop_btn, {
      rv$playing <- FALSE
    })
    
    
    # Click reset btn ----
    observeEvent(input$reset_btn, {
      rv$playing <- FALSE
      rv$idx <- 0L
      leafletProxy(ns('map')) |>
        clearGroup('seq') |>
        clearControls() |>
        addControl(html = div(class = 'hud', 'Reset'),
                   position = 'topright')
    })
    
    


    
    
    # Animation loop ----
    observe({
      req(mode() == 'player', rv$playing)
      sp_data <- data_names()
      req(nrow(sp_data) > 0)
      
      # tick rate
      invalidateLater(input$speed %||% 700, session)
      
      # advance index
      i <- isolate(rv$idx) + 1L
      if (i > nrow(sp_data)){
        # stop at end
        rv$playing <- FALSE
        return()
      }
      
      # current row
      row <- sp_data[i, ]
      
      
      # Date info ----
      output$date_info <- renderUI({
        
        paste0('Obs #: ', i, '/', nrow(sp_data), ' | Observation date: ', row$eventDate)
        
      })
      
      # show exactly one marker, update hud, and pan
      proxy <- leafletProxy(ns('map'), data = row) |>
        clearControls() |>
        addCircleMarkers(
          lng = ~row$longitudeDecimal,
          lat = ~row$latitudeDecimal,
          color = '#F39B37',
          radius = 10, weight = 2, fillOpacity = 0.5,
          group = 'seq'
        ) 
      
      rv$idx <- i
      
      
    })
    
    
    observeEvent(is_visible_tab(), { 

      if(is_visible_tab()){

        bb <- last_bounds()

        session$onFlushed(function(){

          session$sendCustomMessage('leaflet-invalidate-and-fit',
                                    c(list(id = ns('map')), bb ))

        }, once = TRUE)

      }

    }, ignoreInit = TRUE)
    
  })
  
  
}


`%||%` <- function(a, b) if(is.null(a) || !length(a)) b else a
