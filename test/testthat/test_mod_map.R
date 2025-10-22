

test_that('test mod_map_server',{
  
  test_data <- reactiveVal(data.table(lat = c(52.23105, 52.23106, 52.23151),
                                      lng = c(20.96747, 20.96860, 20.97231))
                           )
  
  testServer(mod_map_server, args = list(mydata = test_data, map_type = 'world'),{
    
    expect_silent(output$map)
    
  })
  
  
})





