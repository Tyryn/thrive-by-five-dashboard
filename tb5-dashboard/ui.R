library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(DT)

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
                              fluidRow(
                                column(6,
                                       pickerInput("province_select_a", "Province", 
                                                   choices = province_list, selected=province_list, 
                                                   multiple = TRUE, options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("municipality_select_a", "Municipality type", 
                                                   choices = municipality_list, selected=municipality_list,
                                                   multiple = TRUE, options=pickerOptions(actionsBox = TRUE)))
                              ),
                              fluidRow(
                                column(6,
                                       pickerInput("quintile_select_a", "Quintile", 
                                                   choices = quintile_list, selected=quintile_list,
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("clean_toilets_a", "Clean toilets", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE)))
                              ),
                              fluidRow(
                                column(6,
                                       pickerInput("electricity_a", "Working electricity", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("meal_a", "Meal provided", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE)))
                              ),
                              fluidRow(
                                column(6,
                                       pickerInput("indoor_space_a", "Adequate indoor space", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("books_a", "Has at least 10 books", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE)))
                              )
                          )
                   ),
                   column(6, 
                          box(title = "Comparison sample", width = 12, disabled=TRUE, id="comparison_box",
                              fluidRow(
                                column(6,
                                       pickerInput("province_select_b", "Province", 
                                                   choices = province_list,  selected=province_list, 
                                                   multiple = TRUE, options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("municipality_select_b", "Municipality type", 
                                                   choices = municipality_list, selected=municipality_list, 
                                                   multiple = TRUE, options=pickerOptions(actionsBox = TRUE)))
                              ),
                              fluidRow(
                                column(6,
                                       pickerInput("quintile_select_b", "Quintile", selected=quintile_list,
                                                   choices = quintile_list, multiple=TRUE, options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("clean_toilets_b", "Clean toilets", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE)))
                              ),
                              fluidRow(
                                column(6,
                                       pickerInput("electricity_b", "Working electricity", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("meal_b", "Meal provided", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE)))
                              ),
                              fluidRow(
                                column(6,
                                       pickerInput("indoor_space_b", "Adequate indoor space", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE))),
                                column(6,
                                       pickerInput("books_b", "Has at least 10 books", 
                                                   choices = c("Yes"=1, "No"=0, "Missing"=NA), selected=c("Yes"=1, "No"=0, "Missing"=NA),
                                                   multiple = TRUE,
                                                   options=pickerOptions(actionsBox = TRUE)))
                              )
                          )
                   )
                 )
             )
      )
    ),
    fluidRow(
      column(12,
             box(title = "Output", width = 12,
                 fluidRow(
                   column(4, plotOutput("bar_comp_total")), # First bar graph
                   column(4, plotOutput("bar_comp_gmd")),   # Second bar graph
                   column(4, plotOutput("bar_comp_fmcvmi")) # Third bar graph
                 ),
                 fluidRow(
                   column(4, plotOutput("bar_comp_enm")),   # Fourth bar graph
                   column(4, plotOutput("bar_comp_cef")),        # Fifth bar graph
                   column(4, plotOutput("bar_comp_ell"))    # Sixth bar graph
                 )
             )
      )
    ),
    fluidRow(DT::dataTableOutput("test_table"),style = "height:500px; overflow-y: scroll;overflow-x: scroll;")
  )
)
