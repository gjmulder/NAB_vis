# Shiny server interface for Time Series Visualiastion and annotation
#
# Version 0.1 - Gary Mulder - 26/11/20166

library(shiny)
library(tidyverse)
library(googlesheets)

######################################################################################################


######################################################################################################
# Define server logic required to draw the time series
shinyServer(function(input, output) {
  # State for the UI
  rv <-
    reactiveValues(time_range = list(
      start = min(ts_df$timestamp),
      end = max(ts_df$timestamp)
    ),
    undo_stack = list())
  
  # Main ggplot function
  plot_time_series <-
    function() {
      time_range <-
        rv$time_range
      
      message("=====================================")
      message("Time series: ", input$time_series_name)
      message("Start date : ", strftime(time_range$start, format = "%c"))
      message("End date   : ", strftime(time_range$end, format = "%c"))
      
      # str(ts_df)
      # str(rv$time_range)
      
      ts_df_range <-
        ts_df %>%
        filter(timestamp >= time_range$start &
                 timestamp <= time_range$end)
      ts_df_long_range <-
        ts_df_long %>%
        filter(timestamp >= time_range$start &
                 timestamp <= time_range$end)
      ts_label_range <-
        ts_label %>%
        filter((date.time  + 3600) >= time_range$start &
                 (date.time  + 3600) <= time_range$end)
      
      ggplot() +
        geom_line(data = ts_df_range,
                  aes(x = timestamp, y = value),
                  size = 0.5) +
        geom_jitter(
          data = ts_df_long_range,
          aes(x = timestamp,
              y = metric,
              colour = series),
          # alpha = 0.7,
          # shape = 21,
          size = 2,
          height = 0.1) +
        geom_label(data = ts_label_range,
                   aes(
                     x = date.time + 3600,
                     y = value,
                     label = annotation
                   ))
    }
  
  # UI event state changes we need to handle
  
  # Choose a date range
  observeEvent(input$date_range,
               {
                 message("Date range")
                 rv$time_range$start <-
                   as.POSIXct(input$date_range[1])
                 rv$time_range$end <-
                   as.POSIXct(input$date_range[2])
               })
  
  # Navigate by hour, day or week
  observeEvent(input$minus_hour,
               {
                 message("-1 hour")
                 rv$time_range$start <-
                   rv$time_range$start - 60 * 60
                 rv$time_range$end <-
                   rv$time_range$end - 60 * 60
               })
  observeEvent(input$minus_day,
               {
                 message("-1 day")
                 rv$time_range$start <-
                   rv$time_range$start - 24 * 60 * 60
                 rv$time_range$end <-
                   rv$time_range$end - 24 * 60 * 60
               })
  observeEvent(input$minus_week,
               {
                 message("-1 week")
                 rv$time_range$start <-
                   rv$time_range$start - 7 * 24 * 60 * 60
                 rv$time_range$end <-
                   rv$time_range$end - 7 * 24 * 60 * 60
               })
  observeEvent(input$plus_hour,
               {
                 message("+1 hour")
                 rv$time_range$start <-
                   rv$time_range$start + 60 * 60
                 rv$time_range$end <-
                   rv$time_range$end + 60 * 60
               })
  observeEvent(input$plus_day,
               {
                 message("+1 day")
                 rv$time_range$start <-
                   rv$time_range$start + 24 * 60 * 60
                 rv$time_range$end <-
                   rv$time_range$end + 24 * 60 * 60
               })
  observeEvent(input$plus_week,
               {
                 message("+1 week")
                 rv$time_range$start <-
                   rv$time_range$start + 7 * 24 * 60 * 60
                 rv$time_range$end <-
                   rv$time_range$end + 7 * 24 * 60 * 60
               })
  
  push <-
    function(time_range) {
      # str(rv$undo_stack)
      if (length(rv$undo_stack) > 0)
        rv$undo_stack[[length(rv$undo_stack) + 1]] <-
          time_range
      else
        rv$undo_stack <-
          list(time_range)
    }
  
  pop <-
    function() {
      # str(rv$undo_stack)
      if (length(rv$undo_stack) == 0)
        NULL
      else {
        time_range <-
          rv$undo_stack[[length(rv$undo_stack)]]
        rv$undo_stack[[length(rv$undo_stack)]] <-
          NULL
        time_range
      }
    }
  # Zoom in using a "brush" drag
  observeEvent(input$plot_brush,
               {
                 message("Brush")
                 push(rv$time_range)
                 rv$time_range <-
                   list(
                     start = as.POSIXct(as.integer(input$plot_brush$xmin), origin = "1970-01-01"),
                     end = as.POSIXct(as.integer(input$plot_brush$xmax), origin = "1970-01-01")
                   )
               })
  
  # Unzoom the previous brush drag
  observeEvent(input$unzoom,
               {
                 message("Unzoom")
                 time_range <-
                   pop()
                 if (!is.null(time_range))
                   rv$time_range <-
                   time_range
               })
  
  output$time_series_plot <- renderPlot({
    plot_time_series()
  })
})
