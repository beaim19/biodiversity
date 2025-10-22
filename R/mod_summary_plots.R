
# UI ---------------------------------------------------------------------------


ui_plots_summary <- function(id){
  
  ns <- NS(id)
  
  
    tagList(
      div(id = 'plot-wrap',
          layout_columns(
          card(card_header('Observations by Kingdom'),
               plotOutput(ns('plot_kingdom')), fill = TRUE),
          card(card_header('Seasonal Data'),
               plotlyOutput(ns('plot_season'))),
          card(card_header('Number localities'),
               plotlyOutput(ns('plot_locality')))
          ),
          div(id = ns('overlay_plots'), class = 'overlay',
              uiOutput(ns('overlay_body_plots')))

    )
    
  )
}



# Server -----------------------------------------------------------------------

server_plot_summary <- function(id, 
                                data_slider,  
                                minYear, 
                                maxYear, 
                                latest_country,
                                after_initial, 
                                datessel
                                ){
  
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
    
    slider_ready <- reactiveVal(FALSE)
    
    observeEvent(c(latest_country()), {
      slider_ready(FALSE)
    })
    
    observe({
      #req(nrow(data_slider()) > 0)
      req(datessel()[1])
      slider_ready(TRUE)
    })
    
    
    # Initial message ----
    output$overlay_body_plots <- renderUI({
      
      if (!after_initial()){
        
        tagList(

          div(class = 'starting-message-plot',
              icon("circle-info", class = "fa-2x"), 
              br(),
              HTML(paste0('Please select a country to see a summary of:<br>
              <ul><li>percent of observations by Kingdom</li>
              <li>number of observations by season and year</li>
              <li>number of unique localities where the observations were recorded</li></ul>
              <p style="font-size: 40px; color:#478851ff;">Start Exploring!</p>'))
          )
        )
        
      } else {
        NULL
      }
    })
    
    # Kingdom ----

      data_plotK <- reactive({
        
        req(slider_ready())
        
        req(nrow(data_slider()) > 0)
        
        data_plot <- data_slider()
        
        dataCO_pie <- data_plot[,
                                .(totalCount = .N),
                                by = .(kingdom, scientificName)][,
                                                                 .(totalCount = .N),
                                                                 by = .(kingdom)]
        
        dataCO_pie[is.na(kingdom),
                   kingdom := 'Not defined']
        
        dataCO_pie[,
                   Percent := round(100*totalCount/sum(totalCount), 1)]
        
        setorder(dataCO_pie, -totalCount)
        
        dataCO_pie[, ':='
                   (csum = rev(cumsum(rev(totalCount))))]
        
        dataCO_pie[, ':='
                   (pos = totalCount/2 + shift(csum, type = 'lead'))]
        
        dataCO_pie[,
                   pos := ifelse(is.na(pos), totalCount/2, pos)]
        
        dataCO_pie[,
                   kingdom2 := factor(kingdom,
                                      levels = dataCO_pie$kingdom)]
        
      })
      
      output$plot_kingdom <- renderPlot({
        
        req(slider_ready())

       p <- ggplot(data = data_plotK(),
               aes(x = '', y = totalCount, fill = kingdom2))+
          geom_col(width = 1, color = 1)+
          coord_polar(theta = 'y')+
          scale_fill_manual('Season', values = c('Animalia' = '#E57A77',
                                                 'Plantae' = '#7CA1CC',
                                                 'Not defined' = '#A8B6CC',
                                                 'Fungi' = '#EEBAB4'))+
          geom_label_repel(data = data_plotK(),
                           aes(y = pos, label = paste0(Percent, '%')),
                           size = 4.5, nudge_x = 1, show.legend = FALSE)+
          guides(fill = guide_legend(title = ''))+
          theme_void()+
          theme(legend.position = 'bottom')
        
       p
        
      })
      
    
    
    # Season ----

      
      data_plotS <- reactive({
        
        req(slider_ready())
        
        req(nrow(data_slider()) > 0)
        
        data_plot <- data_slider()
        
        data_plot_S <- data_plot[,
                                 .(N = .N),
                                 by = .(Year, season)]
        
        setorder(data_plot_S, Year, season)
        
      })
      
      output$plot_season <- renderPlotly({
        
        req(slider_ready())
        
        if (maxYear()-minYear() > 20){sepYears <- 2} else {sepYears <- 1}
        
        p <- ggplot(data = data_plotS(),
                    aes(x = Year, y = N, fill = season))+
          geom_bar(stat = 'identity', 
                   position = position_stack(reverse = TRUE), 
                   color = '#fff')+
          scale_fill_manual('', values = c('Winter' = '#0F2080',
                                           'Spring' = '#A95AA1',
                                           'Summer' = '#F5793A',
                                           'Fall' = '#85C0F9'))+
          scale_x_continuous(breaks = seq(minYear(),
                                          maxYear(),
                                          sepYears),
                             limits = c(minYear(), maxYear()+1))+
          xlab('Year')+
          ylab('Total Number of Observations')+
          coord_flip()
        
        
        gp <- ggplotly(tune_plot(p), tooltip = c('x', 'y')) %>%
          layout(legend = list(orientation = "h", x=0, y = -0.3, tracegroupgap = 2, font=list(size = 12)))
        
        gp
        
      })
    
    
    # locality ----
    
    data_plotL <- reactive({
      
      req(slider_ready())
      
      req(nrow(data_slider()) > 0)
      
      data_plot <- data_slider()
      
      data_plot_L <- data_plot[,
                               .(N = length(unique(locality))),
                               by = .(Year)]
      
      
      
    })
    
    output$plot_locality <- renderPlotly({
      
      req(slider_ready())
      
      if (maxYear()-minYear() > 20){sepYears <- 2} else {sepYears <- 1}
      
      p <- ggplot(data = data_plotL(),
                  aes(x = Year, y = N))+
        geom_bar(stat = 'identity', fill = '#E57A77')+
        scale_x_continuous(breaks = seq(minYear(),
                                        maxYear(),
                                        sepYears),
                           limits = c(minYear(), maxYear()+1))+
        xlab('Year')+
        ylab('Total Number Unique Localities')
      
      ggplotly(tune_plot_angle(p))
      
    })
    
    
    
    # overlay ----
    observeEvent(c(latest_country()),{ 
      
      req(latest_country())

      session$onFlushed(function(){
        
        session$sendCustomMessage('fit-and-reveal-plot', c(list(
          wrapId = 'plot-wrap',
          overlayId = ns('overlay_plots'),
          timeout = 1500,
          fallback = 500
        )))
        
      }, once = TRUE)
      
      
    }, ignoreInit = TRUE)
    
    
  })
}





