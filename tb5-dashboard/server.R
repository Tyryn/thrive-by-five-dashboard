
library(shiny)
library(tidyverse)
library(ggplot2)

data <- readRDS("data.RDS")

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
      {if (input$infrastructure_select_a==1) filter(., toilet_clean==1) else filter(., x<3)}
      filter(toilet_clean=)
  })
  
  # Comparison sample
  data_comparison <- reactive({
    data %>% 
      filter(prov_geo %in% input$province_select_b) %>% 
      filter(mn_type %in% input$municipality_select_b) %>% 
      filter(quintile %in% input$quintile_select_b)
  })
  
  # Main sample proportion
  proportion_main <- reactive({
    data_main() %>%
      summarise(
        prop = sum(total_elom_cuts == 3) / n(),
        n = n(),
        lower_bound = binom.test(sum(total_elom_cuts  == 3), n())$conf.int[1],
        upper_bound = binom.test(sum(total_elom_cuts  == 3), n())$conf.int[2])
  })
  
  # Comparison sample proportion
  proportion_comparison <- reactive({
    data_comparison() %>%
      summarise(prop = sum(total_elom_cuts == 3) / n(),
                n=n(),
                lower_bound = binom.test(sum(total_elom_cuts  == 3), n())$conf.int[1],
                upper_bound = binom.test(sum(total_elom_cuts  == 3), n())$conf.int[2])
  })
  
  # Combine proportions into a data frame
  comparison_data <- reactive({
    data.frame(
      Sample = c("Main Sample", "Comparison Sample"),
      Proportion = c(proportion_main()$prop, proportion_comparison()$prop),
      lower_bound = c(proportion_main()$lower_bound, proportion_comparison()$lower_bound),
      upper_bound = c(proportion_main()$upper_bound, proportion_comparison()$upper_bound),
      n = c(proportion_main()$n, proportion_comparison()$n)
    )
  })
  
  # Render the ggplot bar graph with modifications
  output$plot_comparison_group <- renderPlot({
    # Calculate percentage values for y-axis
    comparison_data <- comparison_data()
    
    # Reorder levels of Sample factor
    comparison_data$Sample <- factor(comparison_data$Sample, levels = c("Main Sample", "Comparison Sample"))
    
    # Render the ggplot with modifications
    ggplot(comparison_data, aes(x = Sample, y = Proportion)) +
      geom_bar(stat = "identity", fill = "skyblue") +
      geom_text(aes(label = paste0(round(Proportion*100, 1), "%")), vjust = -0.5) +
      geom_errorbar(aes(ymin = lower_bound, ymax = upper_bound), width = 0.2) +
      scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
      labs(title = "Proportion of Children Achieving the ELOM standard",
           x = "Sample",
           y = "Proportion (%)") +
      theme_minimal()
  })
  
  output$test_table <- renderTable(comparison_data())
  
})
