 library(shiny)
 library("dplyr")
 library("plotly")
# Define UI for application that draws a histogram
 shinyUI(fluidPage( 
  # Application title
   titlePanel("台灣2017年犯罪資料"), # page title
  # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(

            selectInput("city","選擇縣市",choices=c("全台灣","台北市","新北市","桃園市","新竹市","新竹縣","苗栗縣","台中市","彰化縣","雲林縣","嘉義市","嘉義縣","台南市","高雄市","屏東縣","台東縣","花蓮縣","宜蘭縣","基隆市","澎湖縣","金門縣","連江縣")),
            selectInput("criminal_type","犯罪類型",choices=c("全部","毒品","強制性交","汽車竊盜","強盜","機車竊盜","搶奪")),
            sliderInput("bins", # input ID
                        "Number of bins:", #label
                        min = 0,
                        max = 11000,
                        value = 10000), #default value
            textInput("ParticularDate", label = h5("特定日期(格式:1060101)"), value = ""),
            tags$a(href="140.138.77.213:3838/s1076030/FinalProjectMap/", "犯罪之都地圖!!")
          ),  
    # Show a plot of the generated distribution
        mainPanel(
            plotlyOutput("linePlot"),
            tableOutput("criminal_with_population"),
            plotOutput("pie"),
            plotOutput("barPlot") #output ID
            
#            plotOutput("linePlot")
          )
      )
  ))
