library(shiny)

source('roh.R')
source('bcftools.R')
source('plink.R')
source('samtools.R')
source('subsetter.R')
source('vcfr.R')


ui <- fluidPage(
  shinyjs::useShinyjs(),
  titlePanel("Loss of heterozygosity - comparison"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
 #     fileInput(
  #      "file1",
  #      "Choose sequence file",
  #      multiple = TRUE,
  #      accept = c("text/csv", # TODO: allow proper format
  #                 "text/comma-separated-values,text/plain")
  #    ),
      
      textInput("file", "File path", ""),
      hr(),
      
      textInput("sample", "Sample", NULL),
      textInput("chromosome", "Chromosome number", NULL),
      textInput("begin", "Begin", NULL),
      textInput("end", "End", NULL),
      hr(),
      helpText("BCFTools ROH params:"),
      textInput("afDefault", "AF Default", 0.4),
      textInput("plValue", "PL value", 30.0),
      textInput("recRate", "Recombination rate", ""),
      checkboxInput("ignoreHomref", "Skip hom-ref genotypes (0/0)", FALSE),
      checkboxInput("skipIndels", "Skip indels as their genotypes are enriched for errors", FALSE),
      textInput("hwToAz", "Transition probability from HW (Hardy-Weinberg) to AZ (autozygous)", NULL),
      textInput("azToHw", "Transition probability from AZ to HW state", NULL),
      textInput("viterbiTraining", "Estimate HMM parameters, <float> is the convergence threshold, e.g. 1e-10 (experimental)", NULL),
      hr(),
      helpText("PLINK ROH params:"),
      textInput("minSNPCount", "min SNP count"),
      textInput("minLength", "min length"),
      hr(),
      actionButton('run','Run algorithm'),
      verbatimTextOutput("progress")
      
    ),
    # Main panel for displaying outputs ----
    mainPanel(plotOutput("results"),plotOutput("results1"),plotOutput("results2"))
  )
)

getObject <- function(input) {
  task <- list()
  if (!is.null(input$sample) && input$sample != "") {
    task$sample <- input$sample
  }

  task$chromosomes <- list()
  task$chromosomes$chromosome <-input$chromosome
  task$chromosomes$region <- list()
  task$chromosomes$region$begin <-input$begin
  task$chromosomes$region$end <- input$end
  task
}

runBCFToolsROH <- function(output, input, fileName) {
  # BFCTools params
  af.default = 0.4
  pl.value = 30.0
  rec.rate = NULL
  
  ignore.homref = input$ignoreHomref
  skip.indels = input$skipIndels
  hw.to.az <- input$hwToAz
  az.to.hw <- input$azToHw
  viterbi.training<- input$viterbiTraining
  if (input$afDefault > 0) {
    af.default <- input$afDefault
  }
  if (input$plValue > 0) {
    pl.value <- input$plValue
  }
  if (input$recRate > 0) {
    rec.rate <- input$recRate
  }
  
  # Plink params
  snp <- NULL
  if (input$minSNPCount > 0) {
    snp <- input$minSNPCount
  }
  kb <- NULL
  if (input$minLength > 0) {
    kb <- input$minLength
  }
  
  task <- getObject(input) 
  task$vcf_file_name <- fileName
  print(task)
  print(fileName)
  
  print("== subsetter.prepare ==")
  subsetter.prepare.result <- subsetter.prepare(task)

    print("== BCFTools ROH ==")
    bcftools.roh.params <- bcftools.roh.buildparams(subsetter.prepare.result, af.default, pl.value,	ignore.homref, skip.indels, rec.rate)
    bcftools.roh.output <- bcftools.roh.run(bcftools.roh.params)
    
    print("== Plink ROH ==")
    plink.roh.params <- plink.roh.buildparams(subsetter.prepare.result, snp, kb)
    print(plink.roh.params)
    plink.roh.output <- plink.roh.run(plink.roh.params)
    
    
    print("== vcfR BAF ==")
    vcfr.baf.output <- vcfr.baf.from.file(subsetter.prepare.result)
    
    output$results2 <- renderPlot({
    #  input$newplot
     # plot(plink.roh.output) # mock data
      plot(bcftools.roh.output$position, bcftools.roh.output$homozygosity,col="red",cex=0.25)
      
    })
    
    output$results1 <- renderPlot({
      #input$newplot
      plot(plink.roh.output$position, plink.roh.output$homozygosity,col="green",cex=0.25) # mock data
    })
    
    output$results <- renderPlot({
    #  input$newplotx="position"
      plot(vcfr.baf.output$position,vcfr.baf.output$baf,col="blue",cex=0.25)
    })
}

# Define server logic
server <- function(input, output) {
  options(shiny.maxRequestSize=2048*1024^2)
  chromosomes <- reactiveValues()
  uploadedFilePath <- NULL;
  
  output$value <- renderText({ input$sample })
  
#  output$results <- renderPlot({
#    input$newplot
#    cars2 <- cars + rnorm(nrow(cars)) # mock data
#    plot(cars2) # mock data
#  })

  
  output$choosenChromosomes<-renderPrint({
    chromosomes$dList
  })
  
  observe({
    #shinyjs::hide("options", input$alg == "BCFTools") #hide options when alg != BCFTools
    if(input$run > 0) {
      output$progress <- renderText({
        "Work in progress"
      })
      
      data <- runBCFToolsROH(output, input, input$file)
      
      output$progress <- renderText({
        "Done"
      })
    }
    
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
