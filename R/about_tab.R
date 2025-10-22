
text_about <- function(){
  
  tags$div(
    style = 'padding: 1rem',
    tags$h2('How to interact with the maps'),
    br(),
    HTML("<p text-justify>The maps have been built considering clusters in radius of 1km. There are two types of maps: 
    static and dynamic.<br><br>On the static map, the circles represents the number of unique observations in a cluster, 
    or the total number of individuals that were observed in that cluster. 
    Click on the circles to get more info, and feel free to zoom in and out of the map.<br><br>
    The dynamic map shows the sequence of when the
    observations occurred, just click on the start button, and change the speed with the slider.<br><br>
    If you want to know more about the species you selected, click on the <em>Info species</em> button, and you'll get a summary
    on the species and some pictures.<br><br>
         Enjoy!</p>")
  )
}

img_about <- function(){
  
  tags$img(
    src = 'owl.JPG',
    style = 'width: 100%; height: auto; border-radius: 8px;'
  )
}



text_about_us <- function(){
  
  tags$div(
    style = 'padding: 1rem',
    tags$h2('Who we are'),
    br(),
    HTML("<p text-justify>We are backpackers, world travellers, and most importantly, nature lovers. In addition, 
    we enjoy working with data: from looking for and cleaning it, to creating efficient processes to build dashboards 
    and tell stories through data.<br><br>
    This site has been made using <a href = 'https://shiny.posit.co/'>R Shiny</a>, an R package that makes building interactive web applications 
    like this one possible. It's a very powerful tool, and for us, very fun to use!<br><br>
    If you want to see the code, please visit my GitHub account!
         </p>")
  )
}

img_about_us <- function(){
  
  tags$img(
    src = 'patagonia.jpg',
    style = 'width: 100%; height: auto; border-radius: 8px;'
  )
}