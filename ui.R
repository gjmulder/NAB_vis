# Shiny UI design for NAB Results Visualisation
#
# Version 0.1 - Gary Mulder - 26/11/2016

library(shiny)

shinyUI(fluidPage(
  titlePanel("NAB Results Graphical Viewer"),
  
  # The ggplot visualisation area
  plotOutput(
    outputId = "time_series_plot",
    brush = brushOpts(
      id = "plot_brush",
      direction = "x",
      resetOnNew = TRUE
    )
  ),
  
  hr(),
  
  # We display the plots above the controls to maximise horizontal viewing area
  fluidRow(
    column(6,
           dateRangeInput(
             inputId = "date_range",
             label = "Specify a date range, or select an area of the plot to zoom in",
             start = min(ts_df$timestamp),
             end = max(ts_df$timestamp)
           ),
           actionButton(inputId = "minus_week",
                        label = "-1 Week"),
           actionButton(inputId = "minus_day",
                        label = "-1 Day"),
           actionButton(inputId = "minus_hour",
                        label = "-1 Hour"),
           actionButton(inputId = "plus_hour",
                        label = "+1 Hour"),
           actionButton(inputId = "plus_day",
                        label = "+1 Day"),
           actionButton(inputId = "plus_week",
                        label = "+1 Week"),
           actionButton(inputId = "unzoom",
                        label = "Unzoom")
    )
  )
))
