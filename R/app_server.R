#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  
  
  pontuacao <- shiny::reactiveVal(0)
  ordem <- shiny::reactiveVal(1)
  opcao_correta <- shiny::reactiveVal(0)
  qtd <- shiny::reactiveVal(0)
  
  jogo <- shiny::reactive({
    
    input$reiniciar
    
    shiny::isolate({
      
      base <- bandeiras::bandeiras %>% 
        dplyr::mutate(opcoes = purrr::map(texto, ~{
          outras_opcoes <- setdiff(bandeiras::bandeiras$texto, .x)
          incorretas <- sample(outras_opcoes, as.numeric(input$dificuldade) - 1, replace = FALSE)
          c(.x, incorretas)
        })) %>% 
        dplyr::sample_n(input$quantidade)
      
      # reinicia valores
      pontuacao(0)
      ordem(1)
      opcao_correta(0)
      qtd(input$quantidade)
      shinyjs::enable("submeter")
      
    })
    base
  })
  
  jogada <- shiny::reactive({
    jogo()[ordem(),]
  })
  
  atualizar <- shiny::reactive({
    input$submeter
    shiny::isolate({
      # atualiza ordem
      nova_ordem <- ordem() + 1
      ordem(nova_ordem)
      # atualiza pontuacoes
      if (input$opcoes == opcao_correta()) {
        pontuacao_nova <- pontuacao() + 1
        pontuacao(pontuacao_nova)
      }
    })
  })
  
  # atualiza as opcoes para cada jogada
  shiny::observe({
    atualizar()
    pontuacao()
    input$reiniciar
    shiny::isolate({
      opcoes <- jogada()$opcoes[[1]]
      correta <- opcoes[1]
      # embaralha
      opcoes <- sample(opcoes)
      opcao_correta(correta)
      
      shiny::updateRadioButtons(
        session, 
        "opcoes",
        "Op\u00e7\u00f5es",
        opcoes
      )
    })
  })
  
  # atualiza a bandeira para cada jogada
  output$bandeira <- shiny::renderImage({
    atualizar()
    pontuacao()
    input$reiniciar
    shiny::isolate({
      
      if (ordem() - 1 == qtd()) {
        
        pontos <- paste(
          pontuacao(), 
          shiny::isolate({qtd()}), sep = " / "
        )
        
        shinyalert::shinyalert(
          praise::praise(),
          paste("Sua pontua\u00e7\u00e3o foi de", pontos), 
        )
        
        shinyjs::disable("submeter")
        
        ordem(1)
        pontuacao(0)
        opcao_correta(0)
        
        list(src = "")
      } else {
        tmp <- tempfile(fileext = ".gif")
        httr::GET(
          jogada()$imagem, 
          httr::write_disk(tmp, TRUE)
        )
        list(src = tmp)
      }
      
    })
    
  }, deleteFile = TRUE)
  
  
  
  output$pontos <- shiny::renderText({
    input$reiniciar
    paste(
      pontuacao(), 
      shiny::isolate({qtd()}), sep = " / "
    )
  })
  
}
