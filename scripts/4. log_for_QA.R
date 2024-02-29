
#staff_str

if (dir.exists(sp_filepaths[["staff_counts_loc"]])) {
  # select the latest version
  staff_str <- list.files(path = sp_filepaths[["staff_counts_loc"]]) %>%
    dplyr::last() %>%
    paste(sp_filepaths[["staff_counts_loc"]], ., sep = "\\")

} else {
  staff_str <- list.files() %>% 
    str_subset('.xlsx') #this relies on you having one excel file 
}


#logs_str

logs_data <- list.files(path = sp_filepaths[["logs_loc"]]) %>%
  tail(2) %>%
  paste(sp_filepaths[["logs_loc"]], ., sep = "\\")

QSIG_log_loc <- logs_data[grep("Quality Statistics", logs_data)]

CoP_log_loc <- logs_data[grep("Code of Practice", logs_data)] 


#Write it

fileConn<-file(paste0("log_", Sys.Date(), ".", "txt"))
writeLines(c(staff_str, 
             QSIG_log_loc,
             CoP_log_loc,
             format(cut_off_date, "%D")),
           fileConn)
close(fileConn)
              
              
              
      