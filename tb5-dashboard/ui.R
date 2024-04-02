library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)

# Set pickers
province_list <- c("Eastern Cape", "Free State", "Gauteng", "KwaZulu-Natal",
                   "Limpopo", "Mpumalanga", "Northern Cape", "North West",
                   "Western Cape")
municipality_list <- c("Metropolitan Municipality", "Local Municipality")
quintile_names <- c("Quintile 1", "Quintile 2", "Quintile 3", "Quintile 4", "Quintile 5")
quintile_list <- setNames(1:length(quintile_names), quintile_names)
infrastructure_names <- c("Clean toilets", "Working electricity", "Meal provided", "Adequate indoor space")
infrastructure_list <- setNames(1:length(infrastructure_names), infrastructure_names)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Thrive by Five"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Analysis Type", tabName = "analysis_type", icon = icon("chart-line"),
               radioButtons("analysis_type_select", "Select Analysis Type:",
                            choices = c("One sample", "Two samples"), selected = "One sample"))
    )
  ),
  dashboardBody(
    fluidRow(
      column(12,
             box(title = "Sample selector", width = 12,
                 fluidRow(
                   column(6,
                          box(title = "Main sample", width = 12,
                              pickerInput("province_select_a", "Province", 
                                          choices = province_list, selected=province_list, 
                                          multiple = TRUE, options=pickerOptions(actionsBox = TRUE)),
                              pickerInput("municipality_select_a", "Municipality type", 
                                          choices = municipality_list, selected=municipality_list,
                                          multiple = TRUE, options=pickerOptions(actionsBox = TRUE)),
                              pickerInput("quintile_select_a", "Quintile", 
                                          choices = quintile_list, selected=quintile_list,
                                          multiple = TRUE,
                                          options=pickerOptions(actionsBox = TRUE)),
                              pickerInput("infrastructure_select_a", "Infrastructure", 
                                          choices = infrastructure_list, selected=infrastructure_list,
                                          multiple = TRUE,
                                          options=pickerOptions(actionsBox = TRUE))
                          )
                   ),
                   column(6, 
                          box(title = "Comparison sample", width = 12, disabled=TRUE, id="comparison_box",
                              pickerInput("province_select_b", "Province", 
                                          choices = province_list,  selected=province_list, 
                                          multiple = TRUE, options=pickerOptions(actionsBox = TRUE)),
                              pickerInput("municipality_select_b", "Municipality type", 
                                          choices = municipality_list, selected=municipality_list, 
                                          multiple = TRUE, options=pickerOptions(actionsBox = TRUE)),
                              pickerInput("quintile_select_b", "Quintile", selected=quintile_list,
                                          choices = quintile_list, multiple=TRUE, options=pickerOptions(actionsBox = TRUE) 
                              ),
                              pickerInput("infrastructure_select_b", "Infrastructure", 
                                          choices = infrastructure_list, selected=infrastructure_list,
                                          multiple = TRUE,
                                          options=pickerOptions(actionsBox = TRUE))
                          )
                   )
                 )
             )
      )
    ),
    fluidRow(
      column(12,
             box(title = "Output", width = 12,
                 plotOutput("plot_comparison_group")
             )
      )
    ),
    fluidRow(tableOutput("test_table"))
  )
)
