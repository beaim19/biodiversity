
tune_plot <- function(plotName){
  
  p <- plotName +
    theme_bw()+
    theme(plot.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_blank(),
          plot.title = element_text(hjust = 0.5),
          axis.text = element_text(size = 8),
          axis.title.x = element_text(size = 10),
          axis.title.y = element_blank(),
          title = element_text(hjust = 0.5),
          axis.ticks = element_blank(),
          legend.text = ggtext::element_markdown(size = 8),
          legend.position = 'bottom'
    )
  
  return(p)
}


tune_plot_angle <- function(plotName){
  
  p <- plotName +
    theme_bw()+
    theme(plot.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_blank(),
          plot.title = element_text(hjust = 0.5),
          axis.text.y = element_text(size = 8),
          axis.text.x = element_text(size = 8, angle = 90),
          axis.title.y = element_text(size = 10),
          axis.title.x = element_blank(),
          title = element_text(hjust = 0.5),
          axis.ticks = element_blank(),
          legend.text = ggtext::element_markdown(size = 8),
          legend.position = 'bottom'
    )
  
  return(p)
}



getSeason <- function(date){
  
  day_year <- 100*month(date) + lubridate::day(date)
  
  cuts <- base::cut(day_year, breaks = c(0,319,0620,0921,1220,1231)) 
  
  levels(cuts) <- c("Winter","Spring","Summer","Fall","Winter")
  return(cuts)
}



