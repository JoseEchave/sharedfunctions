library(openxlsx)
library(tidyverse)
excel_sheet_by <- function(df,group_var,path,nest_data = "data"){
  nest_data_enquo <- enquo(nest_data)
  group_var_enquo <- enquo(group_var)
  nest_df <- df %>% 
    group_by(!!group_var_enquo) %>% 
    nest()
  
  ls <- nest_df %>% select(nest_data) %>% pull()
  
  names(ls) <- nest_df %>%
    select(!!group_var_enquo) %>%
    pull()
   ls
  write.xlsx(ls,row.names = FALSE, file = path)
}
