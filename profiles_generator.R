library(DBI)
library(RSQLite)



generateProfiles <- function(ammount, output) {
  
  
  retrieveNames <- function(ammount) {
    con <- dbConnect(SQLite(), "names.sqlite")
    query_result <- dbSendQuery(con, "SELECT * FROM NAMES ORDER BY RANDOM() LIMIT ?;")
    query_result <- dbBind(query_result, list(ammount))
    query_result <- dbFetch(query_result)
    return(query_result)
  }
  
}