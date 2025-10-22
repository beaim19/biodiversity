
mod_obs_ui <- function(id){
  
  ns <- NS(id)
  tagList(
    radioGroupButtons(inputId = ns('typeobssel'),
                label = 'Select type of Observation',
                choices = c('Unique Observations',
                            'Total Number of Individuals Observed'),
                selected = 'Unique Observations',
                direction = 'vertical',
                status = 'custom-class')
  )
  
}


mod_obs_server <- function(id){
  
  moduleServer(id, function(input, output, session){
    
    return(reactive(input$typeobssel))
  })
  
  
}

