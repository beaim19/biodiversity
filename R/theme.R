library(sass)
library(bslib)


make_theme <- function() {
  
  base <- bs_theme(
    version = 5,
    bg = 'white',
    fg = 'black',
    bootswatch = "flatly",
    base_font = font_google("Inter"),
    code_font = font_google("Fira Code"),
    heading_font = font_google("Poppins")
  )
  
  # Read my_styles.scss text
  custom_scss <- sass::sass_file("www/_my_styles.scss")
  
  # Add rules
  theme <- base %>% bs_add_rules(list(custom_scss)) 
  
  return(theme)
}


