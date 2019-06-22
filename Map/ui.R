 library(shiny)
 library(leaflet)
# Define UI for miles per gallon application
 shinyUI(fluidPage(
  # Application title
    titlePanel("2017年8月犯罪地圖"),  
  # Sidebar with controls to select the variable to plot against
  # mpg and to specify whether outliers should be included
    sidebarLayout(
        sidebarPanel(
            selectInput("city","選擇縣市",choices=c("桃園市","基隆市")
                        ,selected="桃園市")
          
      #      selectInput("variable", "Variable:",
      #                                    c("Cylinders" = "cyl",
      #                                                            "Transmission" = "am",
     #                                                             "Gears" = "gear")),  
     #       checkboxInput("outliers", "Show outliers", FALSE)
          ),    
    # Show the caption and plot of the requested variable against mpg
        mainPanel(
#            h3(textOutput("caption")),
          
            leafletOutput("map_circle"),
            leafletOutput("map_heat"),
            leafletOutput("map_amount")
            
          )
      )
   ))

