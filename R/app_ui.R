#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    shiny::fluidPage(
      shinyjs::useShinyjs(),
      shinyalert::useShinyalert(),
      shiny::titlePanel("Jogo das bandeiras!"),
      shiny::sidebarLayout(
        shiny::sidebarPanel(
          shiny::radioButtons(
            "dificuldade",
            "Selecione a dificuldade", 
            choices = c(
              "F\u00e1cil" = 2, 
              "M\u00e9dio" = 4, 
              "Dif\u00edcil" = 6
            )
          ),
          
          shiny::sliderInput(
            "quantidade",
            "Quantidade",
            min = 5, 
            max = 192,
            value = 20,
            step = 1
          ),
          
          shiny::actionButton(
            "reiniciar",
            "Reiniciar!"
          )
          
        ),
        shiny::mainPanel(
          
          shiny::h1("Pontua\u00e7\u00e3o: ", shiny::textOutput("pontos")),
          
          shiny::imageOutput("bandeira"),
          
          shiny::radioButtons(
            "opcoes", "Opcoes",
            choices = "Carregando...", 
            inline = TRUE
          ),
          
          shiny::actionButton("submeter", "Submeter")
          
        )
      )
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'bandeiras'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

