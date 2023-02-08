# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:

# The user must update the variable "File" with the file path the "MESH_output_streamflow.csv" file in this script and the "server.R" script

# You can find out more about building applications with Shiny here:
# http://shiny.rstudio.com

rm(list=ls())
library(shiny)

#Load the stream flow csv file
File<-'/project/6008034/calbano/SaintMary-Milk_Hydrathon/MESH-Scripts/Model_Workflow/vector_based_workflow/6_model_runs/SaintMaryMilk_RTE_2/results/MESH_output_streamflow.csv'

Q<-read.csv(File,sep=",")
n<-dim(Q)

#Number of stations - Exclude first two columns and last column
ns<-ceiling((n[2]-3)/2)
nl<-n[1]

#set dates
stat_name<-vector(length = ns)
min_date<-as.Date(paste(as.character(Q$JDAY[1]),"/",as.character(Q$YEAR[1]),sep=""),format='%j/%Y')
max_date<-as.Date(paste(as.character(Q$JDAY[nl]),"/",as.character(Q$YEAR[nl]),sep=""),format='%j/%Y')
start_date<-min_date
stop_date<-max_date

print(start_date)
print(stop_date)

#assing the header names for measured flow skipping the first 2 columns
for (j in 1:ns){
  index=1+j
  meas=j+index
  stat_name[j]<-colnames(Q[meas])
}

shinyUI(fluidPage(
  
  # Application title
  titlePanel("MESH daily plotting application"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("station", "Choose a station:",stat_name,
                  multiple = FALSE, selectize = FALSE),
      sliderInput("dateRange",
                     "Range:",
                     value = c(min_date, end =max_date),
                     min = min_date, max = max_date,
                     ),
      checkboxInput("print_it","Save as PDF",value=FALSE)),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))


# This script is used to produce an RShiny web application to view the measured vs. simulated streamflow for a number of stations.

# The user must update the variable "File" with the file path the "MESH_output_streamflow.csv" file in this script and the "ui.R" script

# You can find out more about building applications with Shiny here:
# http://shiny.rstudio.com

library(shiny)
library(ggplot2)

NSeff<-function(x,y)
{
  NS <- round(1- sum((x-y)^2,na.rm=TRUE)/sum((x-mean(x, na.rm=TRUE))^2, na.rm=TRUE),2)
  return(NS)
}


PBIAS<-function(x,y)
{
  # PB<-round(sum(x-y)*100/sum(x),0)
  PB<-round(sum(x-y, na.rm=TRUE)*100/sum(x, na.rm=TRUE),0)
  return(PB)
}

shinyServer(function(input, output) {
  
  File<-'/project/6008034/calbano/SaintMary-Milk_Hydrathon/MESH-Scripts/Model_Workflow/vector_based_workflow/6_model_runs/SaintMaryMilk_RTE_2/results/MESH_output_streamflow.csv'
  Q<-read.csv(File,sep=",")
  Q[Q < 0]<-NA
  Q$Ndate<-paste(as.character(Q$JDAY),"/",as.character(Q$YEAR),sep="")
  Q$Ndate<-as.Date(Q$Ndate,format = '%j/%Y')
  
  counter=0
  
  output$distPlot <- renderPlot({
    
    #read list from GUI and get column number using the match function
    my_stat<-input$station
    index<-match(my_stat,colnames(Q))
    
    plot_text<- paste(colnames(Q[index]),"NS=",NSeff(Q[,index],Q[,index+1]),
                      " bias = ",PBIAS(Q[,index],Q[,index+1]))
    
    
    stop_date<-input$dateRange[2]
    start_date<-input$dateRange[1]
    subQ<-subset(Q,Ndate>start_date & Ndate<stop_date)
    
    p<-ggplot(subQ, aes(x=Ndate)) + geom_line(aes_string(y=colnames(subQ[index])),color='dodgerblue3',size=1) +
      geom_line(aes_string(y=colnames(subQ[index+1])),color='darkorange3',size=1) +
      ggtitle(plot_text,subtitle="the staticts apply to the entire simulation period not the zoomed in period") +
      scale_x_date(date_labels ="%b %Y") + xlab("") + ylab("Daily flow (m^3/s)")
    
    print(p)
    
    if(input$print_it){
      plot_file=paste(colnames(Q[index]),".pdf",sep="")
      ggsave(plot_file,plot=p,device="pdf")
    }
    
  })
  
})