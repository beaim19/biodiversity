
text_home <- function(){
  
  tags$div(
    style = 'padding: 1rem',
    tags$h2('Welcome to the Biodiversity Datatraveller Dashboard'),
    br(),
    HTML('<p text-justify>This dashboard shows interactive maps and graphs 
                 where the user can see how often, where, when, and how many individuals
                 of a plant or animal species was seen in the selected country.<br><br>
                 The data source is from <a href = "https://www.gbif.org/occurrence/search?dataset_key=8a863029-f435-446a-821e-275f4f641165"
                 target = "_blank">
                 the Global Biodiversity Information Facility.</a><br><br>
                 These data comes from volunteers all around the world, and it helps everyone to know about the biodiversity and richness of each country. 
                 Knowing what we have,
                 helps realize the importance of conservation and taking care of the world, our unique and lovely home.<br><br>
                 Navigate trhough the site selecting different countries and species, to know more about them. 
                 If you like the experience, and you love nature and to observe around, become a volunteer and add what you see when
                 you are exploring nature! Other nature-lovers would love to learn about what you have seen.<br><br>
                 Be part of this big project!</p>')
  )
}

img_home <- function(){
  
  tags$img(
    src = 'carpintero2.png',
    style = 'width: 100%; height: auto; border-radius: 8px;'
  )
}