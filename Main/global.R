library(shiny)
library("dplyr")
library("plotly")

#criminal_data=read.csv("/srv/shiny-server/s1076030/Hw2/10401-10403犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
#criminal_data_part1=read.csv("/srv/shiny-server/s1076030/Hw2/10601-10603_criminal.csv",sep=",",stringsAsFactors=FALSE)

criminal_data_part1=read.csv("/srv/shiny-server/s1076030/FinalProject/10601-10603犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part2=read.csv("/srv/shiny-server/s1076030/FinalProject/10604-10606犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part3=read.csv("/srv/shiny-server/s1076030/FinalProject/10607-10609犯罪資料.csv",sep=",",stringsAsFactors=FALSE)
criminal_data_part4=read.csv("/srv/shiny-server/s1076030/FinalProject/10610-10612犯罪資料.csv",sep=",",stringsAsFactors=FALSE)

#poplutaion_and_area=read.csv("/srv/shiny-server/s1076030/FinalProject/population.csv",sep=",",stringsAsFactors=FALSE)
poplutaion_and_area=read.csv("/srv/shiny-server/s1076030/FinalProject/1-1+土地面積、戶數、人口數、人口密度、年齡結構及扶養比例.csv",sep=",",stringsAsFactors=FALSE)

#DateCharAmount=7