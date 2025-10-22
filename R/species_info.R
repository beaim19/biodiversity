

mod_sp_info_ui <- function(id){
  
  ns <- NS(id)
  
  uiOutput(outputId = ns('sp_info'))
  
}


mod_sp_info_server <- function(id, species_name, dt_names){
  
  moduleServer(id = id,
               module = function(input, output, session){
                 
                 
                   output$sp_info <- renderUI({
                   
                   req(species_name())
                   
                   sp <- dt_names()$scientificName[1]
                   
                   tryCatch({
                     api <- paste0('https://en.wikipedia.org/api/rest_v1/page/summary/',
                                   URLencode(sp, reserved = TRUE))
                     txt <- jsonlite::fromJSON(api)$extract
                     div(p(txt))
                   }, error = function(e){
                     div(em('No summary found'))
                   })
                   
                 })
                 
               })
  
}
