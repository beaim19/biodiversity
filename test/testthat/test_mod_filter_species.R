

test_that('the list of select species updates correctly when selecting country',{
  
  # Create a reactive Values to simulate the reactive data input (country)
  rv <- reactiveValues(data = data.table(my_species = c('A', 'B', 'C')))
  
  # Test
  testServer(mod_species_server, args = list(id = 'id_test',
                                             data = reactive({rv$data})),{
                                               
                                               # simulate selection of B
                                               session$setInputs(speciessel = 'B')
                                               expect_equal(input$speciessel, 'B')
                                               
                                               # update the data as the reactive new data after changing country
                                               rv$data <- data.table(my_species = c('AA', 'BB', 'CC'))
                                               
                                               # re run the observers
                                               session$flushReact()
                                               
                                               # check the older values have been cleared
                                               expect_false(input$speciessel %in%  c('AA', 'BB', 'CC'))
                                               
                                               # new input
                                               session$setInputs(speciessel = 'CC')
                                               expect_equal(input$speciessel, 'CC')
                                               
                                             })
                                             
})



