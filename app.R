######## Install & Load R packages #######################################################################
if (!require("devtools")) install.packages("devtools", repos="http://cran.us.r-project.org")
if (!require("shiny")) install.packages("shiny", repos="http://cran.us.r-project.org")
if (!require("shinycssloaders")) install.packages("shinycssloaders", repos="http://cran.us.r-project.org")
if (!require("ELeFHAnt")) devtools::install_github('praneet1988/ELeFHAnt')
if (!require("patchwork")) install.packages("patchwork", repos="http://cran.us.r-project.org")
library(devtools)
library(shiny)
library(shinycssloaders)
library(ELeFHAnt)
library(patchwork)
##########################################################################################################


options(shiny.maxRequestSize=100000*1024^2)
ui <- fluidPage(

tags$head(includeHTML(("ELeFHAntAnalytics.html"))),
tags$style(HTML("
      body {
        background-color: Lavender;
      }
  ")),
  
  titlePanel(h1("ELeFHAnt: A supervised machine learning approach for label harmonization and annotation of single cell RNA-seq data",style="font-size:20px;color:DarkBlue;font-weight: bold;"),windowTitle = "ELeFHAnt: A supervised machine learning approach for label harmonization and annotation of single cell RNA-seq data"),

  sidebarLayout(
   
    sidebarPanel(
      
      selectInput("Module",
                  label = "Module",
                  choices = c("Celltype Annotation", "Label harmonization", "Deduce Relationship"),
                  selected = "Visualization"),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation'",
        fileInput("reference",
                  label = "Upload Reference (Accepted Format (.rds): Seurat object with Celltypes column in meta data)",
                  accept = c(".rds"))),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation'",
        fileInput("query",
                  label = "Upload Query (Accepted Format(.rds): Seurat object with seurat_clusters column in meta data)",
                  accept = c(".rds"))),

      conditionalPanel(
        condition = "input.Module == 'Label harmonization'",
        fileInput("integrated_reference",
                  label = "Upload Integrated reference (Accepted Format (.rds): Seurat object with Celltypes column in meta data)",
                  accept = c(".rds"))),

      conditionalPanel(
        condition = "input.Module == 'Deduce Relationship'",
        fileInput("reference1",
                  label = "Upload Reference 1 (Accepted Format (.rds): Seurat object with Celltypes column in meta data)",
                  accept = c(".rds"))),

      conditionalPanel(
        condition = "input.Module == 'Deduce Relationship'",
        fileInput("reference2",
                  label = "Upload Reference 2 (Accepted Format (.rds): Seurat object with Celltypes column in meta data)",
                  accept = c(".rds"))),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation'",
        selectInput("annotation_approach", 
                    label = "Annotation approach",
                    choices = c("ClassifyCells", "ClassifyCells_usingApproximation"),
                    selected = "ClassifyCells",
                    multiple = FALSE)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization' || input.Module == 'Deduce Relationship'",
        selectInput("downsample", 
                    label = "Perform downsampling (Enables fast computation)",
                    choices = c("TRUE", "FALSE"),
                    selected = "TRUE",
                    multiple = FALSE)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization' || input.Module == 'Deduce Relationship'",
        numericInput("downsampleto", 
                    label = "Number of cells to downsample to",
                    value = 100)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization' || input.Module == 'Deduce Relationship'",
        numericInput("crossvalidationSVM", 
                    label = "k-fold cross validation SVM (k>0)",
                    value = 10)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization' || input.Module == 'Deduce Relationship'",
        numericInput("ntreeRF", 
                    label = "Number of trees randomForest classifier should grow",
                    value = 500)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Deduce Relationship'",
        numericInput("features", 
                    label = "Number of features to select for training",
                    value = 2000)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation'",
        selectInput("predictedcelltypes", 
                    label = "Color Cells by",
                    choices = c("PredictedCelltype_UsingRF", "PredictedCelltype_UsingSVM", "PredictedCelltype_UsingEnsemble", "Gene Expression"),
                    selected = "PredictedCelltype_UsingEnsemble",
                    multiple = FALSE)),

      conditionalPanel(
        condition = "input.Module == 'Label harmonization'",
        selectInput("harmonizedcelltypes", 
                    label = "Color Cells by",
                    choices = c("HarmonizedLabels_UsingRF", "HarmonizedLabels_UsingSVM", "HarmonizedLabels_UsingEnsemble", "Gene Expression"),
                    selected = "PredictedCelltype_UsingEnsemble",
                    multiple = FALSE)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization'",
        selectInput("DM", 
                    label = "Dimension reduction used on query",
                    choices = c("umap", "tsne"),
                    selected = "umap",
                    multiple = FALSE)),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization'",
        selectInput("Gene", 
                    label = "Select Genes",
                    choices = NULL,
                    selected = NULL,
                    selectize = TRUE,
                    multiple = TRUE)),

      actionButton("submit", label = "Submit"),

      conditionalPanel(
        condition = "input.Module == 'Celltype Annotation' || input.Module == 'Label harmonization'",
        downloadButton('scRNAObjectDownload', 'Download processed scRNA-Seq Seurat Object'))


    ),
    mainPanel(
          tabsetPanel(type = "tabs",
              tabPanel("About ELeFHAnt", fluidRow(
                p(strong("Ensemble Learning for Harmonization and Annotation of Single Cells (ELeFHAnt)"), "provides an easy to use R package for users to annotate clusters of single cells, harmonize labels across single cell datasets to generate a unified atlas and infer relationship among celltypes between two datasets. It provides users with the flexibility of choosing a single machine learning based classifier or letting ELeFHAnt automatically use the power of randomForest and SVM (Support Vector Machines) to make predictions. It has three functions", strong("1) CelltypeAnnotation 2) LabelHarmonization 3) DeduceRelationship"), style="text-align:justify;color:black;background-color:white;padding:20px;border-radius:10px;font-size:15px"),
                p("For", strong("ELeFHAnt R package"), "installation please see", a("GitHub", href = "https://github.com/praneet1988/ELeFHAnt", target = "_blank"), style="text-align:justify;color:black;background-color:white;padding:20px;border-radius:10px;font-size:15px"),
                p("Download processed", strong("reference datasets"), "from", a("Reference Datasets", href = "https://www.dropbox.com/sh/6hd2skriqqlokwp/AAAVol-_qPlCdA4DpERWjkeJa?dl=0", target = "_blank"), "to use as plugins", style="text-align:justify;color:black;background-color:white;padding:20px;border-radius:10px;font-size:15px"),
                p("Please post issues, suggestions and improvements using", a("Issues/Bugs", href = "https://github.com/praneet1988/ELeFHAnt-Shiny", target = "_blank"), style="text-align:justify;color:black;background-color:white;padding:20px;border-radius:10px;font-size:15px"),
                p("Explore and cite our", strong("preprint"), "ELeFHAnt: A supervised machine learning approach for label harmonization and annotation of single cell RNA-seq data", a("Cite", href = "https://www.biorxiv.org/content/10.1101/2021.09.07.459342v1", target = "_blank"), style="text-align:justify;color:black;background-color:white;padding:20px;border-radius:10px;font-size:15px"),
                p("Developed and maintained by", strong("Praneet Chaturvedi and Konrad Thorner"), ". To view other tools and contributions please visit", a("GitHub", href = "https://github.com/praneet1988/", target = "_blank"), style="text-align:justify;color:black;background-color:white;padding:20px;border-radius:10px;font-size:15px")), imageOutput('Pipeline'), imageOutput('Logo')),
              tabPanel("ELeFHAnt Tutorial", fluidRow(
                p(includeMarkdown("ELeFHAnt_README.md")))),
              tabPanel("Plot Visualization", downloadButton('downloadPlot', 'Save Plot'), shinycssloaders::withSpinner(plotOutput("Plot"), size = 3))
          )
      )
  )
)
 server <- function(input, output, session) {

 output$Pipeline <- renderImage({
  list(src = 'www/pipeline.png',
         contentType = 'image/png',
         width = 800,
         height = 450,
         alt = "ELeFHAnt Model")
  }, deleteFile = F)

 output$Logo <- renderImage({
  list(src = 'www/CCHMC-logo.png',
         contentType = 'image/png',
         width = 300,
         height = 150,
         alt = "CCHMC Logo")
  }, deleteFile = F)

 observe({
     if(input$Module == 'Celltype Annotation'){
       inFile <- input$query
       if (is.null(inFile))
        return(NULL)
       query <- readRDS(inFile$datapath)
       DefaultAssay(query) <- "RNA"
       genes <- unique(rownames(query))
       updateSelectizeInput(session, "Gene", 
                         label = "Select Genes",
                         choices = genes, server = TRUE)
    }
 })

 observe({
     if(input$Module == 'Label harmonization'){
       inFile <- input$integrated_reference
       if (is.null(inFile))
        return(NULL)
       integrated_reference <- readRDS(inFile$datapath)
       DefaultAssay(integrated_reference) <- "RNA"
       genes <- unique(rownames(integrated_reference))
       updateSelectizeInput(session, "Gene", 
                         label = "Select Genes",
                         choices = genes, server = TRUE)
    }
 })

 celltypeannotation <- eventReactive(input$submit, {
    if(input$Module == 'Celltype Annotation') {
      reference_read = input$reference
      if (is.null(reference_read))
        return(NULL)
      reference = readRDS(reference_read$datapath)
      query_read = input$query
      if (is.null(query_read))
        return(NULL)
      query = readRDS(query_read$datapath)
      DefaultAssay(reference) = "RNA"
      DefaultAssay(query) = "RNA"
      message('running celltype annotation')
      CelltypeAnnotation(reference = reference, query = query, downsample = input$downsample, downsample_to = input$downsampleto, classification.method = "Ensemble", crossvalidationSVM = input$crossvalidationSVM, validatePredictions = FALSE, selectvarfeatures = input$features, ntree = input$ntreeRF, classification.approach = input$annotation_approach)
    }
      
 })
 
 labelharmonization <- eventReactive(input$submit, {
    if(input$Module == 'Label harmonization') {
      reference_read = input$integrated_reference
      if (is.null(reference_read))
        return(NULL)
      reference = readRDS(reference_read$datapath)
      DefaultAssay(reference) = "integrated"
      LabelHarmonization(perform_integration = FALSE, integrated.atlas = reference, downsample = input$downsample, downsample_to = input$downsampleto, classification.method = "Ensemble", crossvalidationSVM = input$crossvalidationSVM, validatePredictions = FALSE, ntree = input$ntreeRF)
    }
 })

 deducerelationship <- eventReactive(input$submit, {
    if(input$Module == 'Deduce Relationship') {
      reference1_read = input$reference1
      if (is.null(reference1_read))
        return(NULL)
      reference1 = readRDS(reference1_read$datapath)
      reference2_read = input$reference2
      if (is.null(reference2_read))
        return(NULL)
      reference2 = readRDS(reference2_read$datapath)
      DefaultAssay(reference1) = "RNA"
      DefaultAssay(reference2) = "RNA"
      DeduceRelationship(reference1 = reference1, reference2 = reference2, downsample = input$downsample, downsample_to = input$downsampleto, classification.method = "Ensemble", crossvalidationSVM = input$crossvalidationSVM, selectvarfeatures = input$features, ntree = input$ntreeRF)
    }
 })

 output$Plot <- renderPlot({
    if(input$Module == 'Celltype Annotation') {
      if(input$predictedcelltypes != 'Gene Expression') {
        p1=DimPlot(celltypeannotation(), group.by = "seurat_clusters", repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('Query Clusters')
        p2=DimPlot(celltypeannotation(), group.by = input$predictedcelltypes, repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('ELeFHAnt Predictions')
        p1+p2
      }
      else if(input$predictedcelltypes == 'Gene Expression') {
        FeaturePlot(celltypeannotation(), input$Gene, order = TRUE, pt.size = 0.5, reduction = input$DM)
      }
    }
    else if(input$Module == 'Label harmonization') {
      if(input$harmonizedcelltypes != 'Gene Expression') {
        p1=DimPlot(labelharmonization(), group.by = "Celltypes", repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('Atlas Celltypes')
        p2=DimPlot(labelharmonization(), group.by = input$harmonizedcelltypes, repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('ELeFHAnt Harmonization')
        p1+p2
      }
      else if(input$harmonizedcelltypes == 'Gene Expression') {
        FeaturePlot(labelharmonization(), input$Gene, order = TRUE, pt.size = 0.5, reduction = input$DM)
      }
    }
    else if(input$Module == 'Deduce Relationship') {
      deducerelationship()
    }
  }, width=1000, height=1000)

  output$downloadPlot <- downloadHandler(
      filename = function() {
        paste0(input$Module, "_Plot", "-", Sys.Date(), ".png")
      },
      content = function(file) {
        if(input$Module == 'Celltype Annotation') {
          if(input$predictedcelltypes != 'Gene Expression') {
            p1=DimPlot(celltypeannotation(), group.by = "seurat_clusters", repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('Query Clusters')
            p2=DimPlot(celltypeannotation(), group.by = input$predictedcelltypes, repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('ELeFHAnt Predictions')
            p1+p2
            ggsave(file, width=15, height=15, dpi=800)
          }
          else if(input$predictedcelltypes == 'Gene Expression') {
            FeaturePlot(celltypeannotation(), input$Gene, order = TRUE, pt.size = 0.5, reduction = input$DM)
            ggsave(file, width=10, height=10, dpi=800)
          }
        }
        else if(input$Module == 'Label harmonization') {
          if(input$harmonizedcelltypes != 'Gene Expression') {
            p1=DimPlot(labelharmonization(), group.by = "Celltypes", repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('Atlas Celltypes')
            p2=DimPlot(labelharmonization(), group.by = input$harmonizedcelltypes, repel = TRUE, label = TRUE, pt.size = 0.5, label.size = 5, reduction = input$DM) + NoLegend() + ggtitle('ELeFHAnt Harmonization')
            p1+p2
            ggsave(file, width=15, height=15, dpi=800)
          }
          else if(input$harmonizedcelltypes == 'Gene Expression') {
            FeaturePlot(labelharmonization(), input$Gene, order = TRUE, pt.size = 0.5, reduction = input$DM)
            ggsave(file, width=10, height=10, dpi=800)
          }
        }
        else if(input$Module == 'Deduce Relationship') {
          deducerelationship()
          ggsave(file, width=10, height=10, dpi=800)
        }
    },
    contentType = 'image/png'
  )

  output$scRNAObjectDownload <- downloadHandler(
    filename = function() {
        paste0(input$Module, "_Analysis", "-", Sys.Date(), ".rds")
      },
      content = function(file) {
        if(input$Module == 'Celltype Annotation') {
          saveRDS(celltypeannotation(), file = file)
        }
        else if(input$Module == 'Label harmonization') {
          saveRDS(labelharmonization(), file = file)
        }
      }
  )
}
shinyApp(ui = ui, server = server)
