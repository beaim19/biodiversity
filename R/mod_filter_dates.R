
mod_dates_ui <- function(id){
  
  ns <- NS(id)
  tagList(
    uiOutput(ns('datessel1'))
    # sliderInput(inputId = ns('datessel'),
    #             label = 'Choose time range',
    #             min = as.Date('2000-01-01'),
    #             max = as.Date('2019-12-01'),
    #             value = as.Date(c('2000-01-01',
    #                               '2019-12-01'))
    # 
    # )
  )
  
}


mod_dates_server <- function(id, data, minYear, maxYear){
  
  moduleServer(id, function(input, output, session){

    ns <- session$ns
    
    observe({
      data <- data()
      req(nrow(data) > 0 )

      
      minDate <- as.Date(min(data$eventDate, na.rm = TRUE))
      maxDate <- as.Date(max(data$eventDate, na.rm = TRUE))
      
      output$datessel1 <- renderUI({

        sliderInput(label = 'Choose time range',
                    ns('datessel'),
                          min = minDate,
                          max = maxDate,
                          value = c(minDate, maxDate))
      })

      # updateSliderInput(session,
      #                   'datessel',
      #                   min = minDate,
      #                   max = maxDate,
      #                   value = c(minDate, maxDate))
    })
    
    return(reactive(input$datessel))
  })
  
  
}

