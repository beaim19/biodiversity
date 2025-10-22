
mod_country_input_ui <- function(id){
  
  ns <- NS(id)
  
    pickerInput(inputId = ns('countrysel'),
                   label = 'Select Country',
                   choices = NULL,
                   selected = character(0),
                   options = list(
                     placeholder = 'Type Here',
                     onInitialize = I('function() { this.setValue(""); }'))
                )
    
}


mod_country_input_server <- function(id, list_countries, latest_country = NULL){
  
  moduleServer(id, function(input, output, session){
    
    observe({
      
      if (is.null(latest_country())){
        
        shinyWidgets::updatePickerInput(session,
                                      'countrysel',
                                      label = 'Select Country',
                                      choices = sort(names(list_countries)),
                                      selected = character(0),
                                      options = list(
                                        placeholder = 'Type Here',
                                        onInitialize = I('function() { this.setValue(""); }')))
      } else {
        
        shinyWidgets::updatePickerInput(session,
                                        'countrysel',
                                        label = 'Select Country',
                                        choices = sort(names(list_countries)),
                                        selected = latest_country(),
                                        options = list(
                                          placeholder = 'Type Here',
                                          onInitialize = I('function() { this.setValue(""); }')))
        
      }
      
      
    })
    
    return(reactive(input$countrysel))
  })
  
  
}

