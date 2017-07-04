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


################# 1. DATA SOURCES #################

# read in polygon shape file
simp_myAus <- readOGR("simp_myAus.shp", GDAL1_integer64_policy = TRUE)


# read in time series for population
popTS <- read.csv('SA2_POP_TS.csv',
                  header=T,
                  sep=",",
                  quote='"',
                  strip.white=T,
                  stringsAsFactors=F,
                  fill=T)
# reshape
popTS_w <- dcast(popTS,
                 SA2_CODE + STATE + SA2_NAME ~ TIME, 
                 value.var = 'VALUE')

# remove mismatched areas + add rate of change
popTS_w <- popTS_w %>%
  filter(!SA2_CODE %in% setdiff(popTS_w$SA2_CODE, simp_myAus$SA2_5DI)) %>%
  mutate(ratechange06 = round((`2016`-`2006`)/`2006`, 3) *100)


# add additional attributes
simp_myAus$population_2016 <- popTS_w$`2016`
simp_myAus$population_2006 <- popTS_w$`2006`
simp_myAus$population_change <- popTS_w$ratechange06

################# 2. SHINY SERVER FUNCTION #################


server <- function(input,output,sessions) {

  # Create the map
  output$myMap <- renderLeaflet({
    
    population_type <- input$textual_type
    
    #underlying map object - load once
    theMap <- leaflet(simp_myAus) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 135.0000, lat = -24.1500, zoom = 4)
    
    #if statement to determine which sentiment analysis metrics will be shown
    if (population_type == "2016 vs 2006 population change") {
      
      # define bins
      bins <- c(-Inf, -20, -10, -5, -1, 0, 1, 5, 9, 10, 15, 20, 25, 30, 50, 100, Inf)
      
      # construct labels
      labels <- sprintf(
        "<strong>%s</strong><br/>%s percent change in population from 2006 to 2016<br/><ul><li>%s - population in 2016 </li><li>%s - population in 2006 </li></ul>",
        simp_myAus$SA2_NAM, 
        simp_myAus$population_change,
        simp_myAus$population_2016,
        simp_myAus$population_2006
      ) %>% lapply(htmltools::HTML)
      
      # colour pallette
      pal <- colorBin("Greens", 
                      domain = simp_myAus$population_change , 
                      bins = bins)
      
      theMap %>%
        addPolygons(
          fillColor = ~pal(population_change),
          weight = 2,
          opacity = 1,
          color = "white",
          dashArray = "3",
          fillOpacity = 0.7,
          highlight = highlightOptions(
            weight = 5,
            color = "#666",
            dashArray = "",
            fillOpacity = 0.7,
            bringToFront = TRUE),
          label = labels,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto"))  %>%
        addLegend(pal = pal, values = ~population_change, opacity = 0.7, title = NULL,
                  position = "bottomright") %>%
        addMeasure(
          position = "bottomleft",
          primaryLengthUnit = "meters",
          primaryAreaUnit = "sqmeters",
          activeColor = "#3D535D",
          completedColor = "#7D4479")
      
    } else if (population_type == "2016 population by area") {
      
      # define bins
      bins <- c(0, 1000, 5000, 7500, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, Inf)
      
      # construct labels
      labels <- sprintf(
        "<strong>%s</strong><br/>%s - population in 2016 <br/><ul><li>%s - population in 2006 </li><li>%s percent change in population from 2006 to 2016</li></ul>",
        simp_myAus$SA2_NAM, 
        simp_myAus$population_2016,
        simp_myAus$population_2006,
        simp_myAus$population_change
      ) %>% lapply(htmltools::HTML)
      
      # colour pallette
      pal <- colorBin("Oranges", 
                      domain = simp_myAus$population_2016 , 
                      bins = bins)
      
    theMap %>%
      addPolygons(
        fillColor = ~pal(population_2016),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"))  %>%
      addLegend(pal = pal, values = ~population_2016, opacity = 0.7, title = NULL,
                position = "bottomright") %>%
      addMeasure(
        position = "bottomleft",
        primaryLengthUnit = "meters",
        primaryAreaUnit = "sqmeters",
        activeColor = "#3D535D",
        completedColor = "#7D4479")

    } else if (population_type == "2006 population by area") {
      
      # define bins
      bins <- c(0, 1000, 5000, 7500, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000, Inf)
      
      # construct labels
      labels <- sprintf(
        "<strong>%s</strong><br/>%s - population in 2006 <br/><ul><li>%s - population in 2016 </li><li>%s percent change in population from 2006 to 2016</li></ul>",
        simp_myAus$SA2_NAM, 
        simp_myAus$population_2006,
        simp_myAus$population_2016,
        simp_myAus$population_change
      ) %>% lapply(htmltools::HTML)
      
      # colour pallette
      pal <- colorBin("Oranges", 
                      domain = simp_myAus$population_2006 , 
                      bins = bins)
      
      theMap %>%
        addPolygons(
          fillColor = ~pal(population_2006),
          weight = 2,
          opacity = 1,
          color = "white",
          dashArray = "3",
          fillOpacity = 0.7,
          highlight = highlightOptions(
            weight = 5,
            color = "#666",
            dashArray = "",
            fillOpacity = 0.7,
            bringToFront = TRUE),
          label = labels,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto"))  %>%
        addLegend(pal = pal, values = ~population_2006, opacity = 0.7, title = NULL,
                  position = "bottomright") %>%
        addMeasure(
          position = "bottomleft",
          primaryLengthUnit = "meters",
          primaryAreaUnit = "sqmeters",
          activeColor = "#3D535D",
          completedColor = "#7D4479")
      
    } 
    
  })
}
