

test_that('mod_Dates_filter_input works correclty',{
  
  # Create a reactive Values to simulate the reactive data input 
  test_data <- reactiveValues(data = data.table(monthYear = seq(as.Date('2000-01-01'),
                                                                   as.Date('2020-10-01'),
                                                                   by = 'month')))
  

  # test_data <- reactiveVal(initial_data)

  # Test
  testServer(mod_dates_server, args = list(id = 'id_test',
                                           data = reactive({test_data$data})),{
                                             
                                             
                                             # simulate selection of date
                                             session$setInputs(datessel = c(as.Date('2000-01-01'),
                                                                            as.Date('2018-10-01')))
                                             expect_equal(input$datessel, c(as.Date('2000-01-01'),
                                                                            as.Date('2018-10-01')))
                                             
                                             
                                             # update the data as the reactive new data after changing country
                                             test_data$data <- data.table(monthYear = seq(as.Date('2011-01-01'),
                                                                                               as.Date('2015-10-01'),
                                                                                               by = 'month'))
                                             
                                             # re run the observers
                                             session$flushReact()
  
                                             # new input
                                             session$setInputs(speciessel = c(as.Date('2012-01-01'),
                                                                              as.Date('2014-10-01')))
                                             expect_equal(input$speciessel, c(as.Date('2012-01-01'),
                                                                              as.Date('2014-10-01')))
                                             
                                           })
  
})



