
# get the cut off date from the config.yml file
cut_off_date <- (config::get())[["date"]] %>% as.Date()

# get paths to e-learning files
elearning_logs <- get_elearning_logs()

# create an empty list that will be populated in the loop below
courses_list <- list()

for (course in elearning_logs) {
  # apply the same formatting to qsig and cop data
  courses_list[[course]] <- readxl::read_excel(course) %>%
    janitor::clean_names() %>%
    select(email_address, attempt, started_on) %>%
    arrange(email_address, desc(attempt)) %>%
    distinct(email_address, .keep_all = TRUE) %>%
    dplyr::rename(email = email_address) %>%
    filter(attempt>=1) %>%
    separate(started_on, into = c("Date", "Time"), sep = ",") %>%
    transform(Date =as.Date(Date, "%d %B %Y")) %>%
    filter(Date <= cut_off_date) %>% 
    select(-Time, -attempt) %>%
    mutate(course = 1, 
           email = tolower(email)) %>% 
    # encoding errors can convert apostrophes to "&#039;" 
    mutate(email = str_replace_all(email,"&#039;", "\'")) 
}
  
names(courses_list) <- c("QSIG", "CoP")
