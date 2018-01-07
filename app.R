library(shiny)

ui <- fluidPage(
  titlePanel("Loss of heterozygosity - comparison"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      fileInput(
        "file1",
        "Choose sequence file",
        multiple = FALSE,
        accept = c("text/csv", # TODO: allow proper format
                   "text/comma-separated-values,text/plain")
      ),
      
      tags$hr(),
      
      radioButtons(
        "alg",
        "Select algorithm",
        choices = c(H3M2 = "H3M2",
                    Plink = "PLINK"),
        selected = "H3M2"
      )
      
      
      
    ),
    # Main panel for displaying outputs ----
    mainPanel(tableOutput("results"))
  )
)

# Define server logic
server <- function(input, output) {
  output$results <- renderTable({
    matrix <- matrix(c("value1", "value2"), nrow = 2)
    rownames(matrix) <- c('mock', 'table') #TODO: remove mock table
    matrix
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)