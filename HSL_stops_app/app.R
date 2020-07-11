# Load libraries

library(tidyverse)
library(jsonlite)
#devtools::install_github("ropensci/ghql")
library(ghql)
library(leaflet) #For interactive maps

#Connections to GraphQL API
  ##URL of API
  path <- "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
  #Create a GralQL client
  client <- GraphqlClient$new(
    url = path
  )

  qry <- Query$new()
  ##Function to get all the stops
  get_all_stops <- function(){
    qry$query('stops',glue::glue('
      {
    stops {
      id
      gtfsId
      name
      lat
      lon
      zoneId
      parentStation {
      id
      }
      routes {
      gtfsId
      id
      }
  }
  }
      ',.open = "<<", 
      .close = ">>"))  
    response <- client$exec(qry$queries[[length(qry$queries)]])
    result <- fromJSON(response,flatten = TRUE) %>% 
      data.frame()
    result
  }
  #Fetch data of stops
  all_stops <- get_all_stops()

  #Function to get all the stops of a given route
  routes_in_stops <- function(route_gtfsid){
    qry$query('routes',glue::glue('
  {
    routes(ids: "<<route_gtfsid>>") {
    id
    shortName
    longName
    mode
    type
    stops {
    id
    gtfsId
    name
    lat
    lon
    }
  }
      }

      ',.open = "<<", 
      .close = ">>"))  
    response <- client$exec(qry$queries[[length(qry$queries)]])
    result <- fromJSON(response,flatten = TRUE) %>% 
      data.frame()
    result
  } 

#Get stops data frame
routes_for_every_stop <- all_stops %>% 
  mutate(stop_routes = map(data.stops.routes,~.x$gtfsId)) %>% 
  pull(stop_routes) %>% 
  set_names(all_stops$data.stops.gtfsId)

# UI ############
ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 20,
    titlePanel("All next stops in Helsinki from a given stop"),
      selectInput("select_stop",
        "Select starting stop:",
        choices = sort(unique(all_stops$data.stops.name)),
        width = "100%")
  )

)

# Server logic ##########

server <- function(input, output) {
  selected_ID <- eventReactive(input$select_stop,
    {all_stops %>% 
        filter(data.stops.name == input$select_stop) %>% 
        pull(data.stops.gtfsId) %>% head(1)})
   filtered_stops <- eventReactive(input$select_stop,
     {
      filt_stops <-  map_dfr(routes_for_every_stop[selected_ID()][[1]],routes_in_stops) %>% 
         unnest()  %>% 
         group_by(data.routes.shortName) %>% 
         filter(gtfsId == selected_ID() | lag(gtfsId) == selected_ID() | lead(gtfsId) == selected_ID()) %>% 
         group_by(gtfsId,name,lat,lon) %>% 
         summarize(routes_through = paste(data.routes.shortName,collapse = ", ")) %>% 
         mutate(popup = paste(name,": ",routes_through)) 
      filt_stops$label_wrap <- 
        paste0("<b>",filt_stops$name,"<b> ","<br>",
          str_replace_all(str_wrap(filt_stops$routes_through,width = 40),
            "\n",
            "<br>")) %>% 
        lapply(htmltools::HTML)
      filt_stops
     })
   
   icons <- eventReactive(input$select_stop,{
     awesomeIcons(
     icon = ifelse(filtered_stops()$gtfsId == selected_ID(),"glyphicon-pushpin",""),
     library = "glyphicon"
   )
   })
   
   output$map <- renderLeaflet({
     leaflet(filtered_stops())     %>% 
       addTiles() %>% 
       addAwesomeMarkers(~lon,~lat)
  
   })
   
   observe({
     proxy <- leafletProxy("map",data = filtered_stops()) %>% 
       addAwesomeMarkers(~lon,~lat,label = ~label_wrap,
         icon = icons(),
         labelOptions = labelOptions(noWrap = FALSE,opacity = 0.95,textsize = "18px"))
     
   })
}

# Run the application #############
shinyApp(ui = ui, server = server)


