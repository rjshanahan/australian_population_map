#Richard Shanahan  
#https://github.com/rjshanahan  
#rjshanahan@gmail.com
#13 June 2017

################################
###### Mapping Population ###### 
################################

## load packages
library(shiny)
# library(zoo)
# library(xts)
library(ggplot2)
library(reshape2)
library(dplyr)
library(devtools)
# library(forecast)
# library(plotly)
# library(dygraphs)
library(leaflet)
library(rgdal)
library(rmapshaper)


# Choices for drop-downs
selections_Pop <- list('POPULATION'=list('2016 population by area',
                                         '2006 population by area',
                                         '2016 vs 2006 population change'))



############################################################
## shiny user interface function
############################################################


shinyUI(navbarPage("Australian Population Map", 
                   #id="nav", 
                   inverse=TRUE,
                   
                   # MAPPING TAB                   
                   tabPanel("Metrics by Area", icon = icon("map-marker"),
                            
                            div(class="outer",
                                
                                tags$head(
                                  # Include custom CSS
                                  includeCSS("www/styles.css")
                                ),
                                
                                leafletOutput("myMap", width="100%", height="100%"),
                                
                                
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 120, left = "auto", right = 20, bottom = "auto",
                                              width = 400, height = 250,
                                              
                                              h2("Pick your mapping metric"),
                                              h5("In your way? Move me around then!"),
                                              br(),
                                              
                                              selectInput(inputId="textual_type", "Select a population metric", selections_Pop, selected = selections_Pop$POPULATION[1]),
                                              
                                              h5("Where do these data come from? Visit ", a("ABS.stat", href="http://stat.data.abs.gov.au//Index.aspx", target="_blank"))
                                              )
                            ),
                            
                            tags$div(id="cite",
                                     'Data & visualisations compiled by ', tags$em('Richard Shanahan'))
                            )
                   )
        )
