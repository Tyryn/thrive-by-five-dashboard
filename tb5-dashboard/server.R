
library(shiny)
library(tidyverse)
library(ggplot2)
library(haven)

data <- readRDS("data.RDS")

# Functions ##### 

# Function for handling pickerInput with NA
is_val <- function(value, set) {
  if (all(value == "NA")) {
    is.na(set)
  } else {
    if (any(value == "NA")) {
      set %in% value | is.na(set)
    } else {
      set %in% value
    }
  }
}

# List of comparison barplot dataframes
comp_dfs <- c("prop_total", "prop_gmd", "prop_fmcvmi", "prop_enm", "prop_cef", "prop_ell")



# Server logic
shinyServer(function(input, output) {
  observeEvent(input$analysis_type_select,{
    if (input$analysis_type_select == "One sample") return(NULL)
    hide(id = "comparison_box", anim = TRUE)
    #print(input$txtbx)
  })

  # Main bar graph ####

  # Main sample
  data_main <- reactive({
    data %>%
      dplyr::filter(prov_geo %in% input$province_select_a) %>%
      dplyr::filter(mn_type %in% input$municipality_select_a) %>%
      dplyr::filter(quintile %in% input$quintile_select_a) %>%
      dplyr::filter(is_val(input$clean_toilets_a, toilet_clean)) %>%
      dplyr::filter(is_val(input$electricity_a, electricity_working)) %>%
      dplyr::filter(is_val(input$meal_a, meals)) %>%
      dplyr::filter(is_val(input$indoor_space_a, space)) %>%
      dplyr::filter(is_val(input$books_a, books))
  })

  # Comparison sample
  data_comparison <- reactive({
    data %>%
      dplyr::filter(prov_geo %in% input$province_select_b) %>%
      dplyr::filter(mn_type %in% input$municipality_select_b) %>%
      dplyr::filter(quintile %in% input$quintile_select_b) %>%
      dplyr::filter(is_val(input$clean_toilets_b, toilet_clean)) %>%
      dplyr::filter(is_val(input$electricity_b, electricity_working)) %>%
      dplyr::filter(is_val(input$meal_b, meals)) %>%
      dplyr::filter(is_val(input$indoor_space_b, space))  %>%
      dplyr::filter(is_val(input$books_b, books))
  })

  # Main sample proportion

  proportion_dfs <- reactive({
    list_dfs <- list(data_main(), data_comparison())
    list <- lapply(list_dfs, function(df){
      df %>%
        summarise(
          prop_total = sum(total_elom_cuts == 3) / n(),
          prop_gmd = sum(domain_1_cuts == 3) / n(),
          prop_fmcvmi = sum(domain_2_cuts == 3) / n(),
          prop_enm = sum(domain_3_cuts == 3) / n(),
          prop_cef = sum(domain_4_cuts == 3) / n(),
          prop_ell = sum(domain_5_cuts == 3) / n(),
          n = n(),
          lower_bound_prop_total = binom.test(sum(total_elom_cuts  == 3), n())$conf.int[1],
          upper_bound_prop_total = binom.test(sum(total_elom_cuts  == 3), n())$conf.int[2],
          lower_bound_prop_gmd = binom.test(sum(domain_1_cuts  == 3), n())$conf.int[1],
          upper_bound_prop_gmd = binom.test(sum(domain_1_cuts  == 3), n())$conf.int[2],
          lower_bound_prop_fmcvmi = binom.test(sum(domain_2_cuts  == 3), n())$conf.int[1],
          upper_bound_prop_fmcvmi = binom.test(sum(domain_2_cuts  == 3), n())$conf.int[2],
          lower_bound_prop_enm = binom.test(sum(domain_3_cuts  == 3), n())$conf.int[1],
          upper_bound_prop_enm = binom.test(sum(domain_3_cuts  == 3), n())$conf.int[2],
          lower_bound_prop_cef = binom.test(sum(domain_4_cuts  == 3), n())$conf.int[1],
          upper_bound_prop_cef = binom.test(sum(domain_4_cuts  == 3), n())$conf.int[2],
          lower_bound_prop_ell = binom.test(sum(domain_5_cuts  == 3), n())$conf.int[1],
          upper_bound_prop_ell = binom.test(sum(domain_5_cuts  == 3), n())$conf.int[2])
    })
    return(list)
  })

  proportion_main <- reactive(proportion_dfs()[1])
  proportion_comparison <- reactive(proportion_dfs()[2])


  # Combine proportions into a data frame
  comparison_data <- reactive({

    comparison_df <- bind_rows(proportion_main(), proportion_comparison())
    comparison_df$Sample <- c("Main", "Comparison")
    comparison_df$Sample <- factor(comparison_df$Sample, levels = c("Main", "Comparison"))
    return(comparison_df)

  })


  # Create list of bar plots
  # Vector of titles
  graph_titles <- c("Total", "GMD", "FMCVMI", "ENM", "CEF", "ELL")
  
  # Create list of bar plots
  comp_bar_plots <- reactive({
    plots <- lapply(seq_along(comp_dfs), function(i) {
      variable <- comp_dfs[i]
      title <- graph_titles[i]
      ggplot(comparison_data(), aes(x = Sample, y = !!sym(variable))) +
        geom_bar(stat = "identity", fill = "skyblue") +
        geom_errorbar(aes(ymin = !!sym(paste0("lower_bound_", variable)), 
                          ymax = !!sym(paste0("upper_bound_", variable))), width = 0.2) +
        geom_text(aes(label = paste0(round(!!sym(variable) * 100, 1), "%")), vjust = -0.5) +
        scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
        labs(title = title,  # Use the title here
             x = "",
             y = "Proportion (%)") +
        theme_minimal()
    })
    return(plots)
  })


  # Render the ggplot bar graph with modifications
  output$bar_comp_total <- renderPlot({
   comp_bar_plots()[1] 
  })
  output$bar_comp_gmd <- renderPlot({
    comp_bar_plots()[2] 
  })
  output$bar_comp_fmcvmi <- renderPlot({
    comp_bar_plots()[3] 
  })
  output$bar_comp_enm <- renderPlot({
    comp_bar_plots()[4] 
  })
  output$bar_comp_cef <- renderPlot({
    comp_bar_plots()[5] 
  })
  output$bar_comp_ell <- renderPlot({
    comp_bar_plots()[6] 
  })

  
  main_n <- reactive(comparison_data()[1, "n"])
  comparison_n <- reactive(comparison_data()[2, "n"])
  
  output$sample_n <- renderText({
    paste("     Main sample:", main_n(), "; Comparison sample:", comparison_n())
  })
  
#  output$test_table <- renderDataTable(datatable(comparison_data()))

})
