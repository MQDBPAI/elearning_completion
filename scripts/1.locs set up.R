

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

locating <- function(){
  
  config <- config::get()
  
  locations <- paste0(Sys.getenv("USERPROFILE"),
                      config[grepl("loc", names(config))]) %>% as.list()
  
  
  names <- c("logs_loc", "staff_counts_loc", "output_loc")
  names(locations) <- names
  return(locations)
}

locations <- locating()
rm(locating)



################################################################################
##                   Functions for loading the data                           ##
################################################################################


#' Staff Counts function
#'
#' @return Latest staff counts formatted dataframe
#' @export
#'
#' @examples

staffing <- function(){
  
  if (!dir.exists(locations[["staff_counts_loc"]])) {
    
    staff <- list.files() %>% 
      str_subset('.xlsx')
    
    } else {
      
    staff <- list.files(path = locations[["staff_counts_loc"]]) %>%
      dplyr::nth(-2) %>%
      paste(locations[["staff_counts_loc"]], ., sep = "\\")
        
    }
  
  staff <- staff %>% 
    readxl::read_excel(sheet = 2) %>%
    janitor::clean_names() %>%
    select(primary_email_address, 
           group, 
           directorate, 
           division, 
           grade) %>%
    dplyr::rename(email = primary_email_address, area = group) %>%
    transform(area = as.factor(area), 
              directorate = as.factor(directorate), 
              division = as.factor(division)) %>% 
    mutate(email = tolower(email))
  
}





#' SharePoint e-learning logs
#'
#' @return list with logs locations
#' @export
#'
#' @examples

logging <- function(){
  
  logs_data <- list.files(path = locations[["logs_loc"]]) %>%
    tail(2) %>%
    paste(locations[["logs_loc"]], ., sep = "\\")
  
  
  QSIG_log_loc <- logs_data[grep("Quality Statistics", logs_data)]
    
  CoP_log_loc <- logs_data[grep("Code of Practice", logs_data)]  
  
  logs <- list(QSIG = QSIG_log_loc, 
               CoP = CoP_log_loc)
    
}
  


