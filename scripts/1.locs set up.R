

library(tidyverse)

################################################################################
##                         SharePoint LOCATIONS                               ##
################################################################################

#' SharePoint locations
#'
#' @return list with full path in SharePoint to get data from
#' @export
#'
#' @examples

get_sp_filepaths <- function(){
  # get file paths for all data from config.yml file
  config <- config::get()
  
  # prepend user profile to file paths in config.yml file 
  # e.g., C:\\Users\\donneh\\Office for National Statistics...
  sp_filepaths <- paste0(Sys.getenv("USERPROFILE"),
                      config[grepl("loc", names(config))]) %>% as.list()
  
  # create named list for all locations
  location_names <- c("logs_loc", "staff_counts_loc", "output_loc")
  names(sp_filepaths) <- location_names
  return(sp_filepaths)
}

sp_filepaths <- get_sp_filepaths()

################################################################################
##                   Functions for loading the data                           ##
################################################################################


#' Staff Counts function
#'
#' @return Latest staff counts formatted dataframe
#' @export
#'
#' @examples

get_staff_counts <- function(){
  # if you can find the file in SP
  if (dir.exists(sp_filepaths[["staff_counts_loc"]])) {
    # select the latest version
    staff_str <- list.files(path = sp_filepaths[["staff_counts_loc"]]) %>%
      dplyr::last() %>%
      paste(sp_filepaths[["staff_counts_loc"]], ., sep = "\\")
    
  # if you can't find the staff counts file in SP (see config.yml file) 
  # then look in your local repo and select the excel file present
  } else {
    staff_str <- list.files() %>% 
      str_subset('.xlsx') #this relies on you having one excel file 
  }
  # clean and format staff counts data 
  staff <- staff_str %>% 
    readxl::read_excel() %>%
    janitor::clean_names() %>%
    select(email_address, 
           group, 
           directorate, 
           division, 
           grade) %>%
    dplyr::rename(email = email_address, area = group) %>%
    transform(area = as.factor(area), 
              directorate = as.factor(directorate), 
              division = as.factor(division)) %>% 
    mutate(email = tolower(email)) # mixed case emails cause joining issues
  
  return(staff)
  
}

#' SharePoint e-learning logs
#'
#' @return list with logs locations
#' @export
#'
#' @examples

get_elearning_logs <- function(){
  # get last two filepaths from 1.E-learning_logs SP folder
  logs_data <- list.files(path = sp_filepaths[["logs_loc"]]) %>%
    tail(2) %>%
    paste(sp_filepaths[["logs_loc"]], ., sep = "\\")
  
  # identify the qsig and cop logs and name them appropriately
  QSIG_log_loc <- logs_data[grep("Quality Statistics", logs_data)]
    
  CoP_log_loc <- logs_data[grep("Code of Practice", logs_data)]  
  
  # combine the defined filepaths into one list
  logs <- list(QSIG = QSIG_log_loc, 
               CoP = CoP_log_loc)
  return(logs)
  
}




