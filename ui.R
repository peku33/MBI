

ui <- fluidPage(
  shinyjs::useShinyjs(),
  titlePanel("Loss of heterozygosity - comparison"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(

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