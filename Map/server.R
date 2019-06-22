 library(shiny)
 library(leaflet)
 library(leaflet.extras)
 library("dplyr")
 
 
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
   #  print(i)
   if(substring(criminal_data[i,2],6,7)=="00")
   {
     #    i
     criminal_data[i,2]=gsub("00", "01", criminal_data[i,2])
   }
   criminal_data[i,4]=substring(criminal_data[i,3],1,3)
   criminal_data[i,5]=1
   
 }

 colnames(criminal_data)=paste(c("Type","Date","Location","Region","Freq"))

 


  shinyServer(function(input, output) {
    
    


    datasetInput<-reactive({
        #    MapLatLng=TaoyuanLatLng      
      #--------------------------------get the map data
          if(input$city=="桃園市")
          {
            MapLatLng=TaoyuanLatLng
          }
          else
          {
            MapLatLng=KeelungLatLng
          }
      
      Region_data=criminal_data%>%
        filter(Region==input$city)%>%
        filter(Date>1060800)%>%
        filter(Date<1060900)
      
      #--------------------------------------------隨機給予沒有地區的資料一個地區
      for(i in 1:length(Region_data$Type))
      {
        #--------------------------------get the region
        if(nchar(Region_data[i,3])>3)
        {
          Region_data[i,3]=substring(Region_data[i,3],4,6)
        }
        #--------------------------------------give the random place
        if(Region_data[i,3]==input$city)
        {
          random_region=round(runif(1,min=1,max=7),0)
          Region_data[i,3]=MapLatLng[random_region,3]
        }
        #--------------------------------------給予每個地區資料一個隨機的lng及lat經緯度
        for(j in 1:length(MapLatLng$lng))
        {
          
          if(Region_data[i,3]==MapLatLng[j,3])
          {
            random_lng=round(runif(1, min=-0.02, max=0.02),6)
            random_lat=round(runif(1, min=-0.02, max=0.02),6)
            Region_data[i,6]=MapLatLng[j,1]+random_lng
            Region_data[i,7]=MapLatLng[j,2]+random_lat
          }
        }
      }
      colnames(Region_data)=paste(c("Type","Date","Location","Region","Freq","lng","lat"))
      Region_data
      #------------------------------------------------------------
      
    })
  
    

    output$map_circle <- renderLeaflet({
      map_data=datasetInput()
      m1 = leaflet(data=map_data)
      m1 = addTiles(m1) # Add default OpenStreetMap map tiles
      m1=addCircles(m1,lng=~lng,lat=~lat,radius =100,color="red")
      m1 
    })
    

    output$map_amount <- renderLeaflet({
      if(input$city=="桃園市")
        MapLatLng=TaoyuanLatLng
      else
        MapLatLng=KeelungLatLng
      
      map_data=datasetInput()
      Keelung_sum_data=map_data%>%
        group_by(Location)%>%
        summarise(LocationSum=sum(Freq,na.rm=TRUE))
      Keelung_sum_data=merge(Keelung_sum_data,MapLatLng,by="Location")
      
      m3=leaflet(data=Keelung_sum_data)
      m3=addTiles(m3)
      m3=addMarkers(m3,~lng, ~lat, label =~paste(Location,as.character(LocationSum)), labelOptions = labelOptions(noHide = T, textsize = "15px"))
      m3
      
     })
    output$map_heat<-renderLeaflet({
      map_data=datasetInput()
      m2=leaflet(map_data) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
        addWebGLHeatmap(lng=~lng, lat=~lat, size=2000)
      m2
      
    })
    
    
  })
