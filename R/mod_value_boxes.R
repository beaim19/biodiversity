library(shiny)


js_safe <- function(x){gsub("'", "\\\\'", x)}

mod_valuebox_ui <- function(id){
  
  ns <- NS(id)
  
  uiOutput(outputId = ns('valuebox'))
  
}


mod_valuebox_server <- function(id, title, value_to_show){
  
  moduleServer(id = id,
               
               module = function(input, output, session){
                 
                 ns <- session$ns
                 
                 clicked <- reactiveVal(NULL)
                 whole_data <- reactiveVal(NULL)

                 
                   
                 output$valuebox <- renderUI({
           
                       bslib::value_box(
                       title = title,
                       value = value_to_show, 
                       class = 'fixed_value-box'
                     )
                   
                 })
                 
               
               }) # module Server
  
  
  
  
}