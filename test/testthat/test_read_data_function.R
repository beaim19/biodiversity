


test_that('data is uploaded correctly',{

  test_country <- 'Poland'
  short_name <- 'PL'

  list_country_files <- list('Portugal' = 'PT',
                             'Italy' = 'IT',
                             'Georgia' = 'GR',
                             'Poland' = 'PL')

  test_data <- data.table(country = c('Poland', 'Spain', 'Italy'),
                          lat = 1:3,
                          lng = 4:6)
  dir.create('dataT', showWarnings = FALSE)
  saveRDS(test_data, file = paste0('dataT/', 'PL', '_data_test.Rds'))

  test_result <- read_country_files(list_country_files,
                                    test_country)


  expect_s3_class(test_result, "data.table")
  # expect_equal(test_result[country == test_country]$lat == 1)

  unlink("dataT", recursive = TRUE)
})





