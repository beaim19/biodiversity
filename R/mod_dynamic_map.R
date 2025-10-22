


mapUI_dyn <- function(id) {
  ns <- NS(id)
  tagList(
    tagList(#id = 'play-btn',
      div(
      actionBttn(inputId = ns('start_btn'),
                 label = 'Start'),
      
      actionBttn(inputId = ns('stop_btn'),
                 label = 'Stop'),
      
      actionBttn(inputId = ns('reset_btn'),
                 label = 'Reset'),
      
      sliderInput(ns('speed'),
                  'Speed (ms per step)',
                  min = 150,
                  max = 2000,
                  value = 700,
                  step = 50)
       )
    ),
    div(id = 'map-wrap-dyn',
        leafletOutput(ns("map_dyn"), height = '80vh'),

        div(id = ns('overlay_dyn'), class = 'overlay_dyn',
            uiOutput(ns('overlay_body_dyn'))),
        
        
    )
  )
  
}



map_dyn_server <- function(id, data_names2, data_country2, country, species, after_initial2){
  
  moduleServer(id,
               module = function(input, output, session){
                 
                 ns <- session$ns
                 
                 
                 output$map_dyn <- renderLeaflet({
                   
                   message('output map_dyn in action')
                   
                   leaflet() |> #options = leafletOptions(minZoom = 2, maxZoom = 2)
                     addTiles() |>
                     setView(lng = 0, lat = 20, zoom = 2) %>% # 0 20 2
                     addControl(html = div(class = 'hud', 'Pick a Country and Species and click Play'), position = 'topright')
                   
                     
                 })
                 
                 
                 # Map play
                 rv <- reactiveValues(
                   playing = FALSE,
                   idx = 0L
                 )
                 
                 
                 observeEvent(c(country(), species()), {
                   
                   rv$playing <- FALSE
                   rv$idx <- 0L
                   
                   country <- country()
                   sp <- species()
                   sp_data <- data_names2()
                   ct_data <- data_country2()
                   
                   lng1 = min(ct_data$longitudeDecimal, na.rm = TRUE)
                   lat1 = min(ct_data$latitudeDecimal, na.rm = TRUE)
                   lng2 = max(ct_data$longitudeDecimal, na.rm = TRUE)
                   lat2 = max(ct_data$latitudeDecimal, na.rm = TRUE)
                   
                   proxy <- leafletProxy(ns('map_dyn')) |>
                     clearGroup('seq') |>
                     clearControls()
                   
                   if (nrow(sp_data) > 0){
                     proxy |>
                       addControl(html = div(class = 'hud',
                                             sprintf('Ready: %s observations', nrow(sp_data))),
                                  position = 'topright') |>
                       fitBounds(lng1, lat1, lng2, lat2)
                   
                     } else {
                     
                     proxy |>
                         addControl(html = div(class = 'hud',
                                               "No observations for this species"),
                                    position = 'topright')
                   }
                   
                   
                   
                 }, ignoreInit = TRUE)
                 
                 
                 observeEvent(input$start_btn, {
                   sp_data <- data_names2()
                   req(nrow(sp_data) > 0)
                   rv$playing <- TRUE
                   if (rv$idx <= 0L || rv$idx >= nrow(sp_data)) rv$idx <- 0L
                 })
                 
                 observeEvent(input$stop_btn, {
                   rv$playing <- FALSE
                 })
                 
                 observeEvent(input$reset_btn, {
                   rv$playing <- FALSE
                   rv$idx <- 0L
                   leafletProxy(ns('map_dyn')) |>
                     clearGroup('seq') |>
                     clearControls() |>
                     addControl(html = div(class = 'hud', 'Reset'),
                                position = 'topright')
                 })
                 
                 # animation loop
                 observe({
                   req(rv$playing)
                   sp_data <- data_names2()
                   req(nrow(sp_data) > 0)
                   
                   # tick rate
                   invalidateLater(input$speed, session)
                   
                   # advance index
                   i <- isolate(rv$idx) + 1L
                   if (i > nrow(sp_data)){
                     # stop at end
                     rv$playing <- FALSE
                     return()
                   }
                   
                   # current row
                   row <- sp_data[i, ]
                   message(sprintf('row data: %si', row$latitudeDecimal))
                   
                   # show exactly one marker, update hud, and pan
                   proxy <- leafletProxy(ns('map_dyn'), data = row) |>
                     clearGroup('seq') |>
                     clearControls() |>
                     addCircleMarkers(
                       lng = ~row$longitudeDecimal,
                       lat = ~row$latitudeDecimal,
                       radius = 10, weight = 2, fillOpacity = 0.7,
                       group = 'seq'
                     ) 
                   
                   rv$idx <- i
                   
                   
                 })
                 
                 
                 
               })
}