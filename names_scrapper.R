### SCRIPT WEB SCRAPING QUE RETORNA NOMES E SBRENOMES E CRIA UMA BASE DE DADOS EM SQLITE
#### WEB SCRAPING SCRIPT THAT RETURNS PORTUGUESE BRAZILIAN NAMES AND LAST NAMES THEN CREATES AN SQLITE DATABASE FILE

##BUSCA DE NOMES
##EXTRAIDOS DO ARQUIVO SV FORNECIDO PELO SITE brasil.io

library(tidyverse)
library(DBI)
library(rvest)
library(stringi)

#baixa e le o arquivo de nomes
##downloads and reads the names file
url <- "https://data.brasil.io/dataset/genero-nomes/grupos.csv.gz"
download.file(url, destfile = "grupos.csv.gz")
names_list <- read.csv(gzfile("grupos.csv.gz","rf"))%>%
  select(NOME = name, GENERO = classification)

#cria o arquivo names.sqlite, com a tabela NAMES contendo nome e genero
#creates the names.sqlite file
con <- dbConnect(RSQLite::SQLite(), "names.sqlite")
dbWriteTable(con, "NAMES", names_list)
dbDisconnect(con)
rm(con)


#agora precisamos de sobrenomes para esses nomes
#now we need last names for these names

##iremos extrair sorbrenomes da lista encontrada nesse site: http://www.tiltedlogic.org/Familia/surnames-all.php?tree=#char8
##we well get the last names from a list found in this page: http://www.tiltedlogic.org/Familia/surnames-all.php?tree=#char8

url <- "http://www.tiltedlogic.org/Familia/surnames-all.php?tree=#char8"
parsed_page <- read_html(url)
last_names <-  parsed_page %>% html_elements("td.sncol") %>%
    html_elements("a") %>%
    html_text() %>%
    stri_trim()

#cria uma tibble sque vai receber os sobrenomes, também será feito um processo para retirar caracteres estranhos
#creates a tibble to receive names, and strange characters will also be removed

last_names <- tibble(names = last_names,
                     has_strange_character = stri_detect_regex(last_names, pattern = "[^0-9A-Za-z///' ]")) %>%
  filter(has_strange_character == FALSE) %>%
  select(SOBRENOME = names)

#adds adiciona tabela de sobrenomes ao arquivo names.sqlite 
#adds table to the names.sqlitefile

con <- dbConnect(RSQLite::SQLite(), "names.sqlite")
dbWriteTable(con, "LAST_NAMES", last_names)
dbDisconnect(con)
rm(con)
