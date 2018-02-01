library(shiny)

source('roh.R')
source('bcftools.R')
source('plink.R')
source('samtools.R')
source('subsetter.R')
source('vcfr.R')
source('ui.R')

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

runBaf <- function(output, input, subsetter.prepare.result) {
  print("== vcfR BAF ==")
  vcfr.baf.output <- vcfr.baf.from.file(subsetter.prepare.result)
  
  output$results <- renderPlot({
    #  input$newplotx="position"
    plot(vcfr.baf.output$position,vcfr.baf.output$baf,col="blue",cex=0.25)
  })
}

runPlink <- function(output, input, subsetter.prepare.result) {
  # Plink params
  snp <- NULL
  if (input$minSNPCount > 0) {
    snp <- input$minSNPCount
  }
  kb <- NULL
  if (input$minLength > 0) {
    kb <- input$minLength
  }
  
  
  print("== Plink ROH ==")
  plink.roh.params <- plink.roh.buildparams(subsetter.prepare.result, snp, kb)
  print(plink.roh.params)
  plink.roh.output <- plink.roh.run(plink.roh.params)
  
  output$results1 <- renderPlot({
    #input$newplot
    plot(plink.roh.output$position, plink.roh.output$homozygosity,col="green",cex=0.25) # mock data
  })
  
}

runBCFToolsROH <- function(output, input, subsetter.prepare.result) {
  # BFCTools params
  af.default = NULL
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
  
  print("== BCFTools ROH ==")
  bcftools.roh.params <- bcftools.roh.buildparams(subsetter.prepare.result, af.default, pl.value,	ignore.homref, skip.indels, rec.rate)
  bcftools.roh.output <- bcftools.roh.run(bcftools.roh.params)
  
  output$results2 <- renderPlot({
    #  input$newplot
    # plot(plink.roh.output) # mock data
    plot(bcftools.roh.output$position, bcftools.roh.output$homozygosity,col="red",cex=0.25)
    
  })

}

runAlgs <- function(output, input, fileName) {
  task <- getObject(input) 
  task$vcf_file_name <- fileName
  
  print("== subsetter.prepare ==")
  subsetter.prepare.result <- subsetter.prepare(task)
  
  dataBCF <- runBCFToolsROH(output, input, subsetter.prepare.result)
  dataPlink <- runPlink(output, input, subsetter.prepare.result)
  dataBaf <- runBaf(output, input, subsetter.prepare.result)
  
}

# Define server logic
server <- function(input, output) {
  options(shiny.maxRequestSize=2048*1024^2)
  chromosomes <- reactiveValues()
  uploadedFilePath <- NULL;
  
  output$value <- renderText({ input$sample })
  
  output$choosenChromosomes<-renderPrint({
    chromosomes$dList
  })
  
  observe({
    #shinyjs::hide("options", input$alg == "BCFTools") #hide options when alg != BCFTools
    if(input$run > 0) {
      output$progress <- renderText({
        "Work in progress"
      })
      
      runAlgs(output, input, input$file)
      
      output$progress <- renderText({
        "Done"
      })
    }
    
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
