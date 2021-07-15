library(DBI)
library(RSQLite)

generateProfiles <- function(output_type = "csv", ammount = 1000, n_last_names = 2) {
  
  #function that retrieves a data frame of names and gender, whith the ammount of names passes on ammount parameter
  #function função que retorna um data frame de nomes e genero, com a quantidade de nomes passada no parametro ammount
  retrieveNames <- function(ammount) {
    con <- dbConnect(SQLite(), "./names_scraper/names.sqlite")
    query_result <- dbSendQuery(con, "SELECT * FROM NAMES ORDER BY RANDOM() LIMIT ?;")
    query_result <- dbBind(query_result, list(ammount))
    query_result <- dbFetch(query_result)
    dbDisconnect(con)
    
    ammount_of_retreived_names <- nrow(query_result)
    while(ammount_of_retreived_names < ammount) {
      names_left_to_retreive <- ammount - ammount_of_retreived_names
      con <- dbConnect(SQLite(), "./names_scraper/names.sqlite")
      n_query_result <- dbSendQuery(con, "SELECT * FROM NAMES ORDER BY RANDOM() LIMIT ?;")
      n_query_result <- dbBind(n_query_result, list(names_left_to_retreive))
      n_query_result <- dbFetch(n_query_result)
      dbDisconnect(con)
      query_result <- rbind(query_result,n_query_result)
      ammount_of_retreived_names <- nrow(query_result)
    }
    return(query_result)
  }
  profiles_data <- retrieveNames(ammount)
  
  #function that retrieves and attaches the required number of last names to the already retrieved names
  #função que retorna e junta o numero solicitado de sobrenomes aos nomes já retornados
  retrieveLastNames <- function(n_last_names) {
    
    for (last_name_number in 1:n_last_names) {
      
      con <- dbConnect(SQLite(), "./names_scraper/names.sqlite")
      query_result <- dbSendQuery(con, "SELECT * FROM LAST_NAMES ORDER BY RANDOM() LIMIT ?")
      query_result <- dbBind(query_result, list(ammount))
      query_result <- dbFetch(query_result)
      dbDisconnect(con)
      
      ammount_of_retreived_last_names <- nrow(query_result)
      
      while(ammount_of_retreived_last_names < ammount) {
        n_last_names_yet_to_retrieve <- ammount - ammount_of_retreived_last_names
        
        con <- dbConnect(SQLite(), "./names_scraper/names.sqlite")
        n_query_result <- dbSendQuery(con, "SELECT * FROM LAST_NAMES ORDER BY RANDOM() LIMIT ?")
        n_query_result <- dbBind(n_query_result, list(n_last_names_yet_to_retrieve))
        n_query_result <- dbFetch(n_query_result)
        dbDisconnect(con)
        
        query_result <- rbind(query_result, n_query_result)
        ammount_of_retreived_last_names <- nrow(query_result)
      }
      profiles_data$NOME <- paste(profiles_data$NOME, query_result$SOBRENOME)
    }
    return(profiles_data)
  }
  profiles_data <- retrieveLastNames(n_last_names)
  
  #in developement  
  switch (output_type,
          "csv" = write.csv(profiles_data, "profiles_data.csv", sep=";", fileEncoding = "UTF-8", row.names = FALSE),
          "xlsx" = openxlsx::write.xlsx(profiles_data, "profiles_data.xlsx"),
          "sqlite" = dbWriteTable(dbConnect(SQLite(), "profiles.sqlite"), "profiles", profiles_data)
  )
}

generateProfiles(output_type = "csv", ammount = 2000, n_last_names = 2)
