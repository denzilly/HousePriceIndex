
# Three rules to write server function server <- function(input, output){}
# 1. Save objects to display as output$something  (output$something goes to plotOuput("something") in the fluidPage element)
# 2. BUild pbjects to display with render*() 
#       output$something <- renderPlot({ someplot })
# 
# Example of server function that uses renderPlot and reads inputs
# 
# server <- function(input, output){
#   output$hist <- renderPlot({
#     title <- "some plot"
#     hist(rnorm(input$num), main = title)


library(shiny)
library(ggplot2)
library(zoo)








#source functions
source("dataclean.R")



ui <- fluidPage(
  
  
  
  
  #Input 
  
  
  #selectorinput
  selectInput(inputId = "region1",
              label = "Choose a region to compare",
              choice = regions),
  
  #selectorinput
  selectInput(inputId = "region2",
              label = "Choose a region to compare",
              choice = regions),
  
 
  
  #Output
 
  plotOutput("houseplot"),
  
  textOutput("region1"),
  textOutput("region2")
  
)



server <- function(input, output) {
  

  region1 <- reactive({
    input$region1
  })
  
  region2 <- reactive({
    input$region2
  })
  
  
  output$houseplot <- renderPlot({
    p = ggplot() + 
      geom_line(data = eval(parse(text = gsub("-","",region1()))), aes(x = Perioden, y = PrijsindexVerkoopprijzen_1, color = "blue")) +
      geom_line(data = eval(parse(text = gsub("-","",region2()))), aes(x = Perioden, y = PrijsindexVerkoopprijzen_1, color = "red")) +
      xlab('Dates') +
      ylab('price index')+
      scale_color_discrete(name = "Regions", labels = c(region1(), region2()))
    print(p)
  })
  
  
  output$stats <- 
    renderPrint({
      summary(data())
    })
  
}
shinyApp(ui = ui, server = server)