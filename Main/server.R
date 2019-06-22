  
 library(shiny)
 library("dplyr")
 library("plotly")
 library("datasets")
 library("ggplot2")
# criminal_data=criminal_data[-1,]
# criminal_data=criminal_data[-c(length(criminal_data[,1])),]
 criminal_data_part1=criminal_data_part1[-1,]
 criminal_data_part2=criminal_data_part2[-1,]
 criminal_data_part3=criminal_data_part3[-1,] 
 criminal_data_part4=criminal_data_part4[-1,]

 criminal_data=criminal_data_part1
 criminal_data=rbind(criminal_data,criminal_data_part2)
 criminal_data=rbind(criminal_data,criminal_data_part3)
 criminal_data=rbind(criminal_data,criminal_data_part4)

 for(i in 1:length(criminal_data[,1]))
 {
   if(substring(criminal_data[i,2],6,7)=="00")
   {
     criminal_data[i,2]=gsub("00", "01", criminal_data[i,2])
   }
   criminal_data[i,4]=substring(criminal_data[i,3],1,3)
   criminal_data[i,5]=1
 }
 
 colnames(criminal_data)=paste(c("Type","Date","Location","Region","Freq"))
 data=criminal_data%>%
   group_by(Region)%>%
   summarise(RegionSum=sum(Freq,na.rm=TRUE))

 
 data_criminal_amount=criminal_data%>%
   group_by(Type)%>%
   summarise(TypeSum=sum(Freq,na.rm=TRUE))
 
  shinyServer(function(input, output) {
    

    
     datasetInput<-reactive({
  
         
         if(input$city=="全台灣" && nchar(input$ParticularDate)!=7)
         {
           data_criminal_amount
         }
         else if(input$city!="全台灣" && nchar(input$ParticularDate)!=7)
         {
           
           criminal_amount_single_region=criminal_data%>%
             filter(Region==input$city)%>%
             group_by(Type)%>%
             summarise(TypeSum=sum(Freq,na.rm=TRUE))  
           criminal_amount_single_region
         }
         else if(input$city=="全台灣" && nchar(input$ParticularDate)==7)
          {

           data_criminal_amount_date=criminal_data%>%
             filter(Date==input$ParticularDate)%>%
             group_by(Type)%>%
             summarise(TypeSum=sum(Freq,na.rm=TRUE))
           data_criminal_amount_date
         }
         else if(input$city!="全台灣" && nchar(input$ParticularDate)==7)
         {

           criminal_amount_single_region_date=criminal_data%>%
             filter(Date==input$ParticularDate)%>%
             filter(Region==input$city)%>%
             group_by(Type)%>%
             summarise(TypeSum=sum(Freq,na.rm=TRUE))
           criminal_amount_single_region_date
         }

    })
     colnames(poplutaion_and_area)=paste(c("Year","Region","TotalArea","MalePopulation","FemalePopulation","Population",
                                         "FamilyAmount","FA","Density","NotImportant1",
                                         "0-14","0-14percent","15-64","15-64percent","up65","up65percent","NotImportant2"))
     #poplutaion_and_area=gsub("臺", "台", poplutaion_and_area)
     for(i in 1:length(poplutaion_and_area[,1]))
       poplutaion_and_area[i,2]=gsub("臺", "台", poplutaion_and_area[i,2])
     
     #--------------------------------資料圖
      CriminalPopluationDataset<-reactive({
        Region_place=input$city
        pop_in_sigle_area=poplutaion_and_area%>%
        select("Region","15-64","up65")%>%
        filter(Region==Region_place)
       

        if(input$city=="全台灣"){
          criminal_amount=criminal_data%>%
            summarise(CriminalSum=sum(Freq,na.rm=TRUE))  
          colnames(criminal_amount)=paste(c("犯罪事件"))

        }else{
          criminal_amount=criminal_data%>%
            filter(Region==input$city)%>%
            summarise(CriminalSum=sum(Freq,na.rm=TRUE)) 
          pop_in_sigle_area[1,4]=pop_in_sigle_area[1,2]+pop_in_sigle_area[1,3]
          criminal_amount=cbind(pop_in_sigle_area,criminal_amount)
#          criminal_amount[1,5]=round(criminal_amount[1,5],0)
          criminal_amount[1,6]=round(criminal_amount[1,5]/(criminal_amount[1,2]+criminal_amount[1,3]),digits=7)*100
          criminal_amount[1,6]=as.character(criminal_amount[1,6])
          criminal_amount[1,6]=paste(criminal_amount[1,6], "%", sep=" ")   
          colnames(criminal_amount)=paste(c("地區","15歲到64歲","65歲以上","成年人口","犯罪事件","百分比"))
          
        }
        criminal_amount

        
     })
     #----------------------------------圓餅圖
      output$pie<-renderPlot({

        pie_data=datasetInput()
         
         
         a=pie_data$TypeSum
         remove_column=which(a==max(a))
         output=pie_data[remove_column,]
         pie_data<-pie_data[-c(remove_column),]
         count=0
         
         while(count<5){
           a<-pie_data$TypeSum
           if(count%%2==0){
             remove_column=which(a==min(a))
           }else
           {
             remove_column=which(a==max(a)) 
           }
           output=rbind(output,pie_data[remove_column,])
           pie_data<-pie_data[-c(remove_column),]
           count=count+1
         }
         x=paste(output$Type,output$TypeSum)
         pie(output$TypeSum,labels=x)
         
         

      })

#---------------------------------------長條圖
     
    output$barPlot <- renderPlot({
        if(nchar(input$ParticularDate)==7)
        {
          barPlotData=criminal_data%>%
            filter(Date==input$ParticularDate)%>%
            group_by(Region)%>%
            summarise(RegionSum=sum(Freq,na.rm=TRUE))
          
        }
        else{
          barPlotData=criminal_data%>%
            group_by(Region)%>%
            summarise(RegionSum=sum(Freq,na.rm=TRUE))
        }

        show_barPlot=barplot(barPlotData$RegionSum,
                names.arg=barPlotData$Region,
                las=2,
               ylim=c(0,input$bins+1),
                main="2017年的犯罪數量")
        text(show_barPlot, 0, round(barPlotData$RegionSum, 1),cex=1,pos=3) 
        show_barPlot
#        xx <- barplot(dat$freqs, xaxt = 'n', xlab = '', width = 0.85, ylim = ylim,
#                      main = "Sample Sizes of Various Fitness Traits", 
#                      ylab = "Frequency")
        ## Add text at top of bars
#        text(x = xx, y = dat$freqs, label = dat$freqs, pos = 3, cex = 0.8, col = "red")
        ## Add x-axis labels 
#        axis(1, at=xx, labels=dat$fac, tick=FALSE, las=2, line=-0.5, cex.axis=0.5)
        
        
      })

      output$criminal_with_population<-renderTable({
        head(CriminalPopluationDataset(),n=20)
      })
      
      #---------------------------------------折線圖

        output$linePlot<-renderPlotly({
  

          if(input$criminal_type=="全部" && input$city=="全台灣"){
            criminal_amount_by_date=criminal_data%>%
              group_by(Date)%>%
              summarise(criminalSum=sum(Freq,na.rm=TRUE))      
          }
          else if(input$criminal_type!="全部" && input$city=="全台灣"){
            criminal_amount_by_date=criminal_data%>%
              filter(Type==input$criminal_type)%>%
              group_by(Date)%>%
              summarise(criminalSum=sum(Freq,na.rm=TRUE))   
            
          }
          else if(input$criminal_type=="全部" && input$city!="全台灣")
          {
            
            criminal_amount_by_date=criminal_data%>%
              filter(Region==input$city )%>%
              group_by(Date)%>%
              summarise(criminalSum=sum(Freq,na.rm=TRUE))   
          }
          else{
            criminal_amount_by_date=criminal_data%>%
              filter(Type==input$criminal_type)%>%
              filter(Region==input$city)%>%
              group_by(Date)%>%
              summarise(criminalSum=sum(Freq,na.rm=TRUE))     
          }

#          criminal_amount_by_date[1,1]=substr(criminal_amount_by_date[1,],4,7)
#          substr(criminal_amount_by_date[1,],4,7)
#          criminal_amount_by_date[2,1]
#          length(criminal_amount_by_date$Date)
#           x=c(3,1,2,1,1,4)
#           length(x)
           
          for(i in 1:length(criminal_amount_by_date$Date))
          {
            criminal_amount_by_date[i,1]=substr(criminal_amount_by_date[i,1],4,7)
          }
          plot_ly(criminal_amount_by_date, x = ~Date, y = ~criminalSum, type = 'scatter', mode = 'lines')

          
          
      })
        

   })



