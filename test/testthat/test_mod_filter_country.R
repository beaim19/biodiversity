

test_that('mod_filter_country Check that the country selection works properly',{
  
  list_country_files <- list('Portugal' = 'PT',
                             'Italy' = 'IT',
                             'Spain' = 'SP',
                             'Poland' = 'PL')
  
  testServer(mod_country_input_server, args = list(id = 'id_test',
                                                   list_country_files),{
                                                     

    # simulate selection of B
    session$setInputs(countrysel = 'Spain')
    expect_equal(input$countrysel, 'Spain')
    

    
  })
  
})


