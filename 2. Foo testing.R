

staff <- staffing() # staff dataframe - works



logs <- logging()


  courses_list <- list()

  for (course in logs) {

  courses_list[[course]] <- readxl::read_excel(course) %>%
    janitor::clean_names() %>%
    select(email_address, attempt, started_on) %>%
    arrange(email_address, desc(attempt)) %>%
    distinct(email_address, .keep_all = TRUE) %>%
    dplyr::rename(email = email_address) %>%
    filter(attempt>=1) %>%
    separate(started_on, into = c("Date", "Time"), sep = ",") %>%
    transform(Date =as.Date(Date, "%d %B %Y")) %>%
    #filter(Date <= as.Date(date)) %>% 
    select(-Time) %>%
    mutate(course = 1, 
           email = tolower(email)) 
}
  
  names(courses_list) <- c("QSIG", "CoP")

  
  
  rm(staffing,
     logging,
     course,
     locations,
     logs)