#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#input <- list(daterange = as.Date(c("2016-01-01", "2016-01-012")), platform = "MODISA")
library(shiny)
library(dplyr)
southcoast <- raster::crop(rnaturalearth::ne_coastline(), raster::extent(-180, 180, -90, 0))
library(sp)

# Define UI for application that draws a histogram
ui <- fluidPage(

   # Application title
   titlePanel("Ocean colour"),

   # Sidebar with a slider input for number of bins
   sidebarLayout(
      sidebarPanel(
         selectInput("platform", "Platform", choices = c("MODISA", "SeaWiFS")),
         selectInput("algorithm", "Algorithm", choices = c("Johnson", "NASA")),
         checkboxInput("bothalgorithm", "Plot both?", value = FALSE),
         uiOutput("serverDriven"),
         checkboxInput("map", "Map", value = TRUE)
      ),

      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("socPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  get_files <- reactive({
    shinysoc::soc_files(input$platform)
  })
  get_map <- reactive({
    southcoast
  })
   output$socPlot <- renderPlot({
     if (is.null(input$daterange)) return(NULL)
     dat <- raadtools::readchla_johnson(date = as.character(input$daterange[2]), product = input$platform) %>%
       rename(Johnson = chla_johnson, NASA = chla_nasa)
     dat[c("x", "y")] <- roc::bin2lonlat(dat$bin_num, c(MODISA = 4320, SeaWiFS = 2160)[input$platform])
     if (input$bothalgorithm) {
       op <- par(mfrow = c(2, 1))
       plot(dat[c("x", "y")], col = palr::chlPal(dat[["Johnson"]]), pch = ".", main = "Johnson", asp = 1/0.8)
       if (input$map) plot(get_map(), add = TRUE)
       plot(dat[c("x", "y")], col = palr::chlPal(dat[["NASA"]]), pch = ".", main = "NASA", asp = 1/0.8)
       if (input$map) plot(get_map(), add = TRUE)
       par(op)

     } else {
      plot(dat[c("x", "y")], col = palr::chlPal(dat[[input$algorithm]]), pch = ".")
      if (input$map) plot(get_map(), add = TRUE)
     }
   })
   output$serverDriven <-  renderUI({
     files <- get_files()
     tagList(
       dateRangeInput("daterange", "Date Range",
                      start = max(files$date) - 8 * 24 * 3600, end = max(files$date),
                      min = min(files$date), max = max(files$date))
     )
   })
}

# Run the application
shinyApp(ui = ui, server = server)

