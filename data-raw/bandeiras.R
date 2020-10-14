## code to prepare `bandeiras` dataset goes here

library(tidyverse)

u <- "https://www.worldometers.info/geography/flags-of-the-world/"
r <- httr::GET(u)

divs <- r %>% 
  xml2::read_html() %>% 
  xml2::xml_find_all("//div[@class='row']") %>% 
  dplyr::nth(3) %>% 
  xml2::xml_find_all(".//div[@class='col-md-4']")

div <- divs[[1]]

pegar_link_texto <- function(div) {
  caminho_imagem <- div %>% 
    xml2::xml_find_first(".//img") %>% 
    xml2::xml_attr("src") %>% 
    stringr::str_replace("small/tn_", "")
  txt <- div %>% 
    xml2::xml_text()
  
  tibble::tibble(
    texto = txt,
    imagem = paste0("https://www.worldometers.info", caminho_imagem)
  )
}

bandeiras <- purrr::map_dfr(divs, pegar_link_texto, .id = "id")

usethis::use_data(bandeiras, overwrite = TRUE)
