library(DBI)
library(RSQLite)

ammount <- 200000
last_names <- 2
output_type <- "csv"

generateProfiles <- function(ammount, last_names, output_type) {
  retrieveNames <- function(ammount) {
    con <- dbConnect(SQLite(), "names.sqlite")
    query_result <- dbSendQuery(con, "SELECT * FROM NAMES ORDER BY RANDOM() LIMIT ?;")
    query_result <- dbBind(query_result, list(ammount))
    query_result <- dbFetch(query_result)
    dbDisconnect(con)
    
    ammount_of_retreived_names <- nrow(query_result)
    while(ammount_of_retreived_names < ammount) {
      names_left_to_retreive <- ammount - ammount_of_retreived_names
      con <- dbConnect(SQLite(), "names.sqlite")
      n_query_result <- dbSendQuery(con, "SELECT * FROM NAMES ORDER BY RANDOM() LIMIT ?;")
      n_query_result <- dbBind(n_query_result, list(names_left_to_retreive))
      n_query_result <- dbFetch(n_query_result)
      dbDisconnect(con)
      query_result <- rbind(query_result,n_query_result)
      ammount_of_retreived_names <- nrow(query_result)
    }
    
    
    return(query_result)
  }
  
  retrieveLastNames(last_names)
  
  x <- retrieveNames(1000000)
}
