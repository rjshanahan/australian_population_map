#Richard Shanahan  
#https://github.com/rjshanahan  
#rjshanahan@gmail.com
#13 June 2017

################################
###### Mapping Population ###### 
################################

## load packages
library(shiny)
library(reshape2)
library(dplyr)
library(leaflet)
library(rgdal)
library(rmapshaper)



# Choices for drop-downs
selections_Pop <- list('POPULATION'=list('2016 vs 2006 population change',
                                         '2016 population by area',
                                         '2006 population by area'))



############################################################
## shiny user interface function
############################################################


shinyUI(navbarPage("", 
                   #id="nav", 
                   inverse=TRUE,
                   
                   # MAPPING TAB                   
                   tabPanel("Australian Population Map", icon = icon("map-marker"),
                            
                            div(class="outer",
                                
                                tags$head(
                                  # Include custom CSS
                                  includeCSS("www/styles.css")
                                ),
                                
                                leafletOutput("myMap", width="100%", height="100%"),
                                
                                
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 130, left = 20, right = "auto", bottom = "auto",
                                              width = 360, height = 180,
                                              
                                              br(),
                                              
                                              selectInput(inputId="textual_type", h3("Select a population metric"), selections_Pop, selected = selections_Pop$POPULATION[1]),
                                              
                                              
                                              h5("Where do these data come from? Visit ", a("ABS.stat", href="http://stat.data.abs.gov.au//Index.aspx", target="_blank")),
                                              
                                              h6('View ', a("full size", href='https://tictochomeloans.shinyapps.io/population_map/', target="_blank"))
                                              )
                            ),
                            
                            tags$div(id="cite",
                                     'Compiled by ', tags$em('Tic:Toc Home Loans'))
                            )
                   )
        )
