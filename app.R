library(shiny)

source('roh.R')
source('bcftools.R')
source('plink.R')
source('samtools.R')
source('subsetter.R')


ui <- fluidPage(
  shinyjs::useShinyjs(),
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
        choices = c(BCFTools = "BCFTools",
                    Plink = "PLINK"),
        selected = "BCFTools"
      ),
      textInput("sample", "Sample", ""),
      textInput("chromosome", "Chromosome number", ""),
      textInput("begin", "Begin", ""),
      textInput("end", "End", ""),
      actionButton('run','Run algorithm')
      
    ),
    # Main panel for displaying outputs ----
    mainPanel(plotOutput("results"))
  )
)

getObject <- function(input) {
  task <- list()
  task$chromosome <-input$chromosome
  task$sample <- input$sample
  task$region <- list()
  task$region$begin <-input$begin
  task$region$end <- input$end
  task
}


runBCFToolsROH <- function(input, fileName) {
  task <- getObject(input) 
  task$vcf_file_name <- fileName
  print(task)
  print(fileName)
  
  print("== subsetter.prepare ==")
  subsetter.prepare.result <- subsetter.prepare(task)
  if (input$alg == "BCFTools") {
    print("== BCFTools ROH ==")
    bcftools.roh.params <- bcftools.roh.buildparams(subsetter.prepare.result)
    print(bcftools.roh.params)
    bcftools.roh.output <- bcftools.roh.run(bcftools.roh.params)
    print(bcftools.roh.output)
  } else {
    plink.roh.params <- plink.roh.buildparams(subsetter.prepare.result)
    print(plink.roh.params)
    plink.roh.output <- plink.roh.run(plink.roh.params)
    print(plink.roh.output)
  }

}

# Define server logic
server <- function(input, output) {
  options(shiny.maxRequestSize=2048*1024^2)
  chromosomes <- reactiveValues()
  uploadedFilePath <- NULL;
  
  output$value <- renderText({ input$sample })
  
  output$results <- renderPlot({
    input$newplot
    cars2 <- cars + rnorm(nrow(cars)) # mock data
    plot(cars2) # mock data
  })

  
  output$choosenChromosomes<-renderPrint({
    chromosomes$dList
  })
  
  observe({
    #shinyjs::hide("options", input$alg == "BCFTools") #hide options when alg != BCFTools
    if(input$run > 0) {
      runBCFToolsROH(input, input$file1$datapath)
    }
    
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
