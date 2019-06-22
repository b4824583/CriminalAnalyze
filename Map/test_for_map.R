

library(leaflet)
library("dplyr")
library("plotly")
library(leaflet.extras)
KeelungLatLng=read.csv("/srv/shiny-server/s1076030/FinalProjectSubProgram/Taoyuan.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part1=read.csv("/srv/shiny-server/s1076030/FinalProject/10601-10603犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part2=read.csv("/srv/shiny-server/s1076030/FinalProject/10604-10606犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part3=read.csv("/srv/shiny-server/s1076030/FinalProject/10607-10609犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part4=read.csv("/srv/shiny-server/s1076030/FinalProject/10610-10612犯罪資料.csv",sep=",",stringsAsFactors=FALSE)


criminal_data_part1=criminal_data_part1[-1,]
criminal_data_part2=criminal_data_part2[-1,]
criminal_data_part3=criminal_data_part3[-1,] 
criminal_data_part4=criminal_data_part4[-1,]

criminal_data=criminal_data_part1
criminal_data=rbind(criminal_data,criminal_data_part2)
criminal_data=rbind(criminal_data,criminal_data_part3)
criminal_data=rbind(criminal_data,criminal_data_part4)
#criminal_data[1,2]

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
#substring(data[2,3],4,6)
colnames(criminal_data)=paste(c("Type","Date","Location","Region","Freq"))

#-------------------test code
#data=criminal_data%>%
#  group_by(Region)%>%
#  summarise(RegionSum=sum(Freq,na.rm=TRUE))

#barPlotData=criminal_data%>%
#  filter(Date=="1060317")%>%
#  group_by(Region)%>%
#  summarise(RegionSum=sum(Freq,na.rm=TRUE))

#barplot(barPlotData$RegionSum,
#        names.arg=barPlotData$Region,
#        las=2,
#        ylim=c(0,50),
#        main="2017年的犯罪數量")
#data=data[-1,]
#-------------------

Keelung_data=criminal_data%>%
  filter(Region=="桃園市")%>%
  filter(Date>1060800)%>%
  filter(Date<1060900)
#--------------------------------------------隨機給予沒有地區的資料一個地區
for(i in 1:length(Keelung_data$Type))
{

    if(nchar(Keelung_data[i,3])>3)
    {
      Keelung_data[i,3]=substring(Keelung_data[i,3],4,6)
    }
    if(Keelung_data[i,3]=="桃園市")
    {
      random_region=round(runif(1,min=1,max=7),0)
      Keelung_data[i,3]=KeelungLatLng[random_region,3]
      
    }
  #--------------------------------------給予每個地區資料一個隨機的lng及lat經緯度
    for(j in 1:length(KeelungLatLng$lng))
    {

      if(Keelung_data[i,3]==KeelungLatLng[j,3])
      {
        random_lng=round(runif(1, min=-0.02, max=0.02),6)
        random_lat=round(runif(1, min=-0.02, max=0.02),6)
        Keelung_data[i,6]=KeelungLatLng[j,1]+random_lng
        Keelung_data[i,7]=KeelungLatLng[j,2]+random_lat
      }
    }
}

colnames(Keelung_data)=paste(c("Type","Date","Location","Region","Freq","lng","lat"))

Keelung_sum_data=Keelung_data%>%
  group_by(Location)%>%
  summarise(LocationSum=sum(Freq,na.rm=TRUE))
Keelung_sum_data=merge(Keelung_sum_data,KeelungLatLng,by="Location")

m = leaflet(data=Keelung_data)
m = addTiles(m) # Add default OpenStreetMap map tiles
m=addCircles(m,lng=~lng,lat=~lat,radius =100,color="red")
m 

map=leaflet(data=Keelung_sum_data)
map=addTiles(map)

map=addMarkers(map,~lng, ~lat, label =~paste(Location,as.character(LocationSum)), labelOptions = labelOptions(noHide = T, textsize = "15px"))
map

leaflet(Keelung_data) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
  addWebGLHeatmap(lng=~lng, lat=~lat, size=2000)

