# This is an application exemplifying how to visualize the shapefiles from dialect atlases with package ggplot2.

# 1. Load all the necessary packages (if the packages are not yet installed, do so using install.packages("packagename")).
library(shiny)
library(sf)
library(dplyr)
library(ggplot2)
library(ggrepel)

# 2. Make a list of the map files.
maps <- list.files("Shapefiles", pattern = "^[0-9].*$")
df <- data.frame(Maps = maps, Numbers = as.numeric(gsub("^([0-9]+)_.*$", "\\1", maps))) # join map names with their numbers into a data frame

# 3. Read in parish shapefile for plot base
parishes <- st_read("estParishDialects/estParishDialects.shp", options = "ENCODING=latin1")
parishes <- st_transform(parishes, crs = st_crs(3301)) # transform the coordinate reference system

# 4. Read in the table with atlas contents
atlasEst <- read.delim("VMA_sisukord.txt", fileEncoding = "UTF-8")
# create an English version
atlasEng <- rename(atlasEst, 
                   "Map.nr" = "Kaardi.nr", "Title" = "Pealkiri","Map.Type" = "Kaarditüüp", "Phenomenon.Type" = "Kaardisisu")
atlasEng$Map.Type %>% recode("Tsitaat" = "Text", "Sümbol" = "Symbols", "Piirjoontega" = "Borders", "Viirutustega" = "Cross hatchings", "Sümbol ja viirutused" = "Symbol & cross hatchings") -> atlasEng$Map.Type
atlasEng$Phenomenon.Type %>% recode("Morfoloogia" = "Morphology", "Sõnavara" = "Vocabulary", "Konstruktsioon" = "Construction") -> atlasEng$Phenomenon.Type

# 5. Create dialect polygons
dialect_borders <- parishes %>% group_by(Dialect_en) %>% summarise()  

##########################################################

############
#### UI ####
############
ui <- shinyUI(fluidPage(
    
    # 6. Application title
    titlePanel("Display maps from Andrus Saareste's \"Väike eesti murdeatlas\" (1955)"),
    
    # 7. Introduction
    p("This is an application that offers a simple visualization of the data from Andrus Saareste's 'Väike eesti murdeatlas' (1955). Generating the map for the first time may take a few seconds. If the number of different variants exceeds 106, plotting symbols is no longer possible."),
    
    # 8. The rest if the UI
    fluidRow(
        column(3,
               selectInput("Phenomenon", label = "Choose the phenomenon:", choices = arrange(df, Numbers) %>% select(Maps)),
               actionButton("Update", "Update"),
               br(),
               br(),
               selectInput("Symbols", label = "How to display the variants?", choices = c("symbols", "text", "labels"), selected = "symbols"),
               conditionalPanel("input.Symbols != 'symbols'",
                                checkboxInput("Overlap", label = "Avoid overlap"), value = FALSE),
               sliderInput("Size", label = "Change the size of the symbols/text", min = 1, max = 10, step = 0.1, value = 2),
               checkboxInput("Parishes", label = "Display parish names", value = FALSE),
               textInput("Title", label = "Enter the title of the map"),
               selectInput("Legend", label = "Display the legend...", choices = c("on the right", "at the bottom", "on the left"), selected = "at the bottom"),
               checkboxInput("Dialects", label = "Show dialect areas on the map", value = FALSE),
               radioButtons("Extension", label = "Choose file type for downloading:", choices = c("png", "tiff", "pdf"), selected = "png"),
               downloadButton("Download", label = "Download map")
               ),
        column(7,
               tabsetPanel(
                   tabPanel("Map",
                            plotOutput("map", height = "auto")),
                   tabPanel("Input table",
                            dataTableOutput("tbl")),
                   tabPanel("Contents in Estonian",
                            dataTableOutput("contentsEST")),
                   tabPanel("Contents in English",
                            dataTableOutput("contentsENG"))
               ))
        )
    )
)

################
#### SERVER ####
################

server <- function(input, output, session) {
    
    # 9. Read in the shapefile according to the user's choice
    shpfile <- reactive({
        input$Update
        isolate({
            withProgress({
                setProgress(message = "Loading...")
                shp_path <- paste("Shapefiles/", input$Phenomenon, "/", input$Phenomenon, ".shp", sep = "")
                shpf <- st_transform(st_read(shp_path), crs = st_crs(3301)) # transform the crs
                shpf <- filter(shpf, !is.na(Keelend)) # keep only the rows where Variant column doesn't have a missing value
                shpf <- cbind(shpf, st_coordinates(shpf)[,1:2]) # get the coordinates for the data points in separate columns
                return(shpf)
            })
        })
        
    })
    
    # 10. Choose symbols, text, or labels for plotting (size depends on the user's choices)
    symbols_text <- reactive({
        if(input$Symbols=="symbols"){
            geom_sf(aes(shape = Keelend), show.legend = "point", size = input$Size, fill = "red")
        }
        else if(input$Symbols=="text"){
            if(input$Overlap==TRUE){ # to avoid overlap, draw lines from data points to text
                geom_text_repel(aes(label = Keelend, x = X, y = Y), size = input$Size)
            }
            else{
                geom_sf_text(aes(label = Keelend), size = input$Size) # or just ignore the overlap
            }
        }
        else{
            if(input$Overlap==TRUE){ # to avoid overlap, draw lines from data points to labels
                geom_label_repel(aes(label = Keelend, x = X, y = Y), size = input$Size)
            }
            else{
                geom_sf_label(aes(label = Keelend), size = input$Size) # or just ignore the overlap
            }
        }
    })
    
    # 11. Choose, whether to plot also parish names
    parish_names <- reactive({
        if(input$Parishes==TRUE){
           geom_sf_text(data = parishes, aes(label = Parish_id), alpha = 0.5)
        }
    })
    
    # 12. Choose, where to position the legend
    legend_position <- reactive({
        if(input$Legend=="at the bottom"){
            theme(legend.position = "bottom")
        }
        else if(input$Legend=="on the left"){
            theme(legend.position = "left")
        }
        else{
            theme(legend.position = "right")
        }
    })
    
    # 13. Choose, whether to also mark dialect areas with different colors
    dialects <- reactive({
        if(input$Dialects==TRUE){
            geom_sf(data = dialect_borders, aes(fill = Dialect_en), alpha = 0.3) 
        }
    })
    
    # 14. The function creating the map
    plotInput <- function(){
        ggplot(data = shpfile())+
            geom_sf(data = parishes, fill = "antiquewhite1") +
            dialects() +
            parish_names() +
            symbols_text() +
            scale_shape_manual(values = c(0:25,33:112), name = "Variant") +
            theme(axis.text = element_blank(),
                  axis.ticks = element_blank(),
                  axis.title = element_blank(),
                  panel.background = element_rect(fill = "white"),
                  panel.grid = element_line(colour = NULL),
                  legend.text = element_text(size = 12),
                  plot.title = element_text(face = "bold", hjust = 0.5, size = 28)) +
            legend_position() +
            ggtitle(input$Title)
    }
    
    # 15. Create the map
    output$map <- renderPlot({
        plotInput()
    }, height=function() {
        session$clientData$output_map_width * 0.7
    })
    
    # 16. Downloading function
    output$Download <- downloadHandler(
        filename = function() {paste(input$Phenomenon, "_Saareste_1955_", ".", input$Extension, sep="")},
        content = function(file) {
            ggsave(file, plot = plotInput(), device = input$Extension, width = 18, height = 12, units = "in", dpi = 600)
        }
    )
    
    # 17. Display the input table
    output$tbl <- renderDataTable({
        st_set_geometry(shpfile(), NULL) %>% select(MNIMI, SaKhkLyh, SaKhk, SaKyla, Keelend)
    })
    
    # 18. Display the contents of the atlas in Estonian
    output$contentsEST <- renderDataTable({
        atlasEst
    })
    
    # 19. Display the contents of the atlas in English
    output$contentsENG <- renderDataTable({
        atlasEng
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

