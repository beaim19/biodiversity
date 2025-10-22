


initmsg_show <- function(after_initial){
  
  renderUI({

    show_message <- !after_initial()
    

    if(show_message){
      
      tags$div(
        style = "padding: 40px; text-align: center;",
        tags$div(
          style = "font-size: 24px; font-weight: bold; color: #333;",
          icon("circle-info", class = "fa-2x"), # style = "color: #007BFF; margin-bottom: 10px; font-size: 50px;"
          tags$br(),
          HTML(paste0('Please select a country and a species<br>by their Vernacular or Scientific Name<br>', 
                      'to see how many times it was<br>observed and where<br>
          <p style="font-size: 40px; color:#478851ff;">Start Exploring!</p>'))
        )
      )
    } else {
      NULL
    }
  }
  
  )
  
  
  
}






