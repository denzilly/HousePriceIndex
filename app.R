# Begin apps with template
# Add input and output elements to fluidPage
# Assemble outputs from inputs in the server funciton

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
#
#
# Using reactive() to cache data values, and ensure the same data is used in processing
#
# In server function, create a reactive object, such as:
#
#   Data <- reactive({
#     rnorm(input$num)
#   })
#
#   Now reference data() instead of input$num in other server function outputs
#
#
# Using isolate() to prevent reaction
#
#
#

library(shiny)
library(ggplot2)
library(zoo)


regions <- c('Nederland', 'Noord-Nederland', 'Oost-Nederland','West-Nederland','Zuid-Nederland', 'Groningen', 'Friesland', 'Drenthe', 'Overijssel', 'Flevoland', 'Gelderland', 'Utrecht', 
             'Noord-Holland', 'Zuid-Holland', 'Zeeland', 'Noord-Brabant', 'Limburg', 'Amsterdam','Den-Haag','Rotterdam','Utrecht (Gemeente)')


#Data cleaning and shit

price_data <- read.csv("pbk_regio_note.csv", header = TRUE, sep = ";")
loc_metadata <- read.csv("loc_codes.csv", header = TRUE, sep = ";")



# add region codes
colnames(price_data)[2] <- "Code"
price_data$Landsdeel <- loc_metadata$Landsdeel[match(price_data$Code, loc_metadata$Code, nomatch = 1)]
gsub("-", "_", price_data$Landsdeel)


# Separate Quarterly and Annual
price_data$freq <- "Q"
price_data$freq[grepl("KW", price_data$Perioden) == FALSE] <- "Y"

# Separate DF for quarterly, set date properly
q_d <- price_data[price_data$freq == "Q",]
q_d$Perioden <- as.yearqtr(q_d$Perioden, "%YKW%q")

# Create separate quarterly TS objects for each region
for (x in unique(q_d$Landsdeel)){
  assign(x, zoo(as.matrix(q_d[q_d$Landsdeel == x,4]), as.yearqtr(q_d$Perioden, "%YKW%q"), header = TRUE))
}

# test ts maker
utrecht <- q_d[q_d$Landsdeel == "Utrecht",]
limburg <- q_d[q_d$Landsdeel == "Limburg",]




print(p)











ui <- fluidPage(
  #Input 
  
  #slider
  sliderInput(inputId = "num",
              label = "Choose a number",
              value = 25, min = 1, max = 100),
  
  #selectorinput
  selectInput(inputId = "region",
              label = "Choose a region to compare",
              choice = regions),
  
  #textinput
  textInput(inputId = "title",
            label = "choose a plot title",
            value = "Enter text here"),
  
  #Output
  plotOutput("hist"),
  plotOutput("houseplot"),
  verbatimTextOutput("stats")
  
)
server <- function(input, output) {
  
  data <- reactive({
    rnorm(input$num)
    region(input$region)
  })
  
  
  output$plot2 <- renderPlot({
    p = ggplot() + 
      geom_line(data = utrecht, aes(x = Perioden, y = PrijsindexVerkoopprijzen_1), color = "blue") +
      geom_line(data = limburg, aes(x = Perioden, y = PrijsindexVerkoopprijzen_1), color = "red") +
      xlab('Dates') +
      ylab('price index')
    
  })
  
  
  output$hist <- renderPlot({
    title = "normal dist with n = slider"
    hist(rnorm(data()), main = input$title)
    
  })
  output$stats <- 
    renderPrint({
      summary(data())
    })
  
}
shinyApp(ui = ui, server = server)