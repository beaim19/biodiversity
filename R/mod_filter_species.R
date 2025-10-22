
mod_species_ui <- function(id){
  
  ns <- NS(id)
  
  shinyWidgets::pickerInput(inputId = ns('speciessel'),
                            label = 'Search Vernacular/Scientific Name',
                            choices = '',
                            selected = NULL,
                            options = pickerOptions(
                              liveSearch = TRUE,
                              liveSearchPlaceholder = 'Select Country First',
                              size = 10,
                              container = 'body'
                            ),
                            width = "100%"
  )

}


mod_species_server <- function(id, data){
  
  moduleServer(id, function(input, output, session){

    ns <- session$ns
    
    observe({


      data <- data()

      req(nrow(data) > 0 )

      species_choices <- c(sort(unique(data$vernacularName)), sort(unique(data$scientificName)))
      
      shinyWidgets::updatePickerInput(session,
                           'speciessel',
                           choices = c('Select Species', species_choices),
                           selected = 'Select Species',
                           options = pickerOptions(liveSearchPlaceholder = 'Search')
      )
      
    })
    
    return(reactive(input$speciessel))
  })
  
  
}

