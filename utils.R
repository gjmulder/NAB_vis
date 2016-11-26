library(tidyverse)

######################################################################################################
# Load NAB results data

ts_df <-
  read_csv("~/Work/NAB/results/bayesChangePt/dataSet/bayesChangePt_1460150520_1466762920.csv")
# read_csv("~/Work/NAB/results/contextOSE/dataSet/contextOSE_1460150520_1466762920.csv")
summary(ts_df)

ts_df_long <-
  ts_df %>%
  select(-value) %>%
  gather(series, metric, -timestamp)

######################################################################################################
# Connect to Google Shetts for Labels

setwd("~/Work/ronan/")
googlesheets::gs_auth(token = "shiny_app_google_sheet_token.rds")
sheet_key <-
  "1D6nHybwCpanaw0pynRRWfFJ2QRtIMvIXw8rm2s0xGos"
gsheet_ts_annotations <-
  googlesheets::gs_key(sheet_key)

print(gs_ws_ls(gsheet_ts_annotations))

ts_name <-
  "desktop.orders"
print(paste0("Loading:>", ts_name, "<"))
print(gs_ws_ls(gsheet_ts_annotations))
ts_label <-
  gs_read(gsheet_ts_annotations,
          ws = ts_name)
str(ts_label)
