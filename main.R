library(tidyverse)

setwd("D:/Dirs/e-learning_completion/")

################################
##    1. data set up         ##
################################

staff <- ".\\2023_08_MQD_naughty_list\\04_Staff Counts 31 July 2023.xlsx"
cop <- ".\\2023_08_MQD_naughty_list\\codeofpractice Introduction to the Code of Practice for Statistics.xlsx"
qsig <- ".\\2023_08_MQD_naughty_list\\QualityStats Quality Statistics in Government.xlsx"
date <- "2023-09-05"
month <- "August"


################################
##    2. staff data           ##
################################

staff_df <- readxl::read_excel(staff, sheet = 2) %>%
  janitor::clean_names() %>%
  select(primary_email_address, group, directorate, division, grade, person_number) %>%
  dplyr::rename(email = primary_email_address, area = group) %>%
  transform(area = as.factor(area), directorate = as.factor(directorate), division = as.factor(division)) %>% 
  mutate(email = tolower(email))



################################
##   3. learning hub data     ##
################################

#' Formatting the Learning Hub outputs
#'
#' @param course the path to where the output from learning hub lives
#'
#' @return a dataframe with email, attempts, date, completion
#' @export
#'
#' @examples qsig_df <- completion(".\\e-learning\\qsig.xlsx")
#'
completion <- function(course){
  readxl::read_excel(course) %>%
    janitor::clean_names() %>%
    select(email_address, attempt, started_on) %>%
    arrange(email_address, desc(attempt)) %>%
    distinct(email_address, .keep_all = TRUE) %>%
    dplyr::rename(email = email_address) %>%
    filter(attempt>=1) %>%
    separate(started_on, into = c("Date", "Time"), sep = ",") %>%
    transform(Date =as.Date(Date, "%d %B %Y")) %>%
    filter(Date <= as.Date(date)) %>% 
    select(-Time) %>%
    mutate(course = 1, 
           email = tolower(email)) 
}

cop_df <- completion(cop) %>% rename(cop = course, cop_attempts = attempt, cop_date = Date)
qsig_df <- completion(qsig) %>% rename(qsig = course, qsig_attempts = attempt, qsig_date = Date)

rm(cop, date,qsig,staff, completion)


################################
##    4. Holly testing        ##
################################


all_training <- merge(cop_df, qsig_df, all.x = TRUE, all.y = TRUE, by = "email")

all_training$email <- gsub("&#039;", "\'", all_training$email)

testing_df <- merge(staff_df, all_training, all.x = TRUE, all.y = TRUE, by = "email") #outer join to investigate 
#what's not being matched and why

#Test 1
# checking for duplicate emails (there would be if people do not get merged
# as they should and appear twice in a list

ss_dup <- ss %>% 
  group_by(email) %>% 
  summarize(n = n()) %>% 
  filter ( n != 1) #prints no email = 8, we're good


# Test 2
# checking for ONS people that have not been matched and understanding why


ss_unmatched <- ss %>% 
  filter(is.na(area)) %>% 
  filter(str_detect(email, "ons.gov.uk")) %>%
  arrange(desc(cop_date)) %>% 
  filter(!(str_detect(email, "ext.ons.gov.uk")))


##Getting metrics about the unmatched people




################################
##    5. Merging dfs          ##
################################


#' Merges qsig, cop and staff counts
#'
#' @param staff_df
#' @param cop_df
#' @param qsig_df
#'
#' @return dataframe with area, directorate,division,id, grade, cop and qsig completion for 6k employees
#' @export
#'
#' @examples
#'
merging <- function(staff_df, cop_df, qsig_df){
  fs <- merge(cop_df, qsig_df, all.x = TRUE, all.y = TRUE, by = "email")
  
  fs$email <- gsub("&#039;", "\'", fs$email)
  
  ss <- merge(staff_df, fs, all.x = TRUE, by = "email") %>%
    select(area, directorate, division, email, person_number, grade, cop, qsig) %>%
    arrange(area, directorate, division) %>%
    replace_na(list(cop = 0, qsig = 0))
}

fd <- merging(staff_df, cop_df, qsig_df) %>% select(-person_number)

rm(cop_df, qsig_df, staff_df, merging)


##############################################################################
################################
##    6. Metrics              ##
################################

cop_prc <- round(sum(fd$cop)/nrow(fd)*100,2)

qsig_prc <- round(sum(fd$qsig/nrow(fd)*100), 2)

all_ONS <- data.frame("month" = "July_2023","cop" = cop_prc, "qsig" = qsig_prc)

rm(cop_prc,qsig_prc)

###############################################################################


################################
##    7. Breakdowns           ##
################################



#' List with various breakdowns
#'
#' @param fd
#'
#' @return list with breakdowns by ONS areas and grades
#' @export
#'
#' @examples
breakdowns <- function(fd){
  
  group <- fd %>%
    group_by(area) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  directorate <- fd %>%
    group_by(area, directorate) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  divisions <- fd %>%
    group_by(area, directorate, division) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  grade <- fd %>%
    group_by(grade) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  breakdowns <- list(group = group,
                     directorate = directorate,
                     divisions = divisions,
                     grade = grade)
  
}

breakdown_list <- breakdowns(fd)
rm(breakdowns)


################################
##      8. Export            ##
################################


MQD <- fd %>% filter(directorate == "Methodology and Quality") %>%
  filter(cop == 0 | qsig == 0)

export <- list("ONS_metrics" = all_ONS,
               "by_group" = breakdown_list[["group"]],
               "by_directorate" = breakdown_list[["directorate"]],
               "by_divisions" = breakdown_list[["divisions"]],
               "by_grade" = breakdown_list[["grade"]],
               "all_data" = fd,
               "MQD_incomplete_list" = MQD)

writexl::write_xlsx(export, paste0(".\\2023_08_MQD_naughty_list\\", month, "_export.xlsx"))




########### testing
#test names with hyphens & apostrophes
#check the 2 people who were caught out last time - done
## could even do a manual check of all 42 people in the incomplete list 
#once we have the new data but will need data from LH!
#Would be better to automate instead of manual check but would take time

#check if email is best to merge on 
#person number is different for some people -  some missing
#everyone has an email address - easier to track through the data in QA

#test the filter lines in completion function
#checking to see if 1 as a string works the same as 1 as an integer and it does
completion <- function(course){
  readxl::read_excel(course) %>%
    janitor::clean_names() %>%
    select(email_address, attempt, started_on) %>%
    arrange(email_address, desc(attempt)) %>%
    distinct(email_address, .keep_all = TRUE) %>%
    dplyr::rename(email = email_address) %>%
    filter(attempt>="1") %>%
    separate(started_on, into = c("Date", "Time"), sep = ",") %>%
    transform(Date =as.Date(Date, "%d %B %Y")) %>%
    filter(Date <= as.Date(date)) %>% 
    select(-Time) %>%
    mutate(course = 1)
}

cop_df <- completion(cop) %>% rename(cop = course, cop_attempts = attempt, cop_date = Date)

#test a different way of summing - sum brackets include whole calculate not just qsig column
qsig_prc <- round(sum(fd$qsig/nrow(fd)*100), 2)
#sum just the qsig column
qsig_prc2 <- round(sum(fd$qsig)/nrow(fd)*100, 2)
##same results 

#test another way to write the mean part in the breakdowns function
breakdowns <- function(fd){
  
  group <- fd %>%
    group_by(area) %>%
    summarize(cop_prc = round(nrow(fd[fd$cop==1, ])/nrow(fd)*100, 2),
              qsig_prc = round(nrow(fd[fd$qsig==1, ])/nrow(fd)*100, 2))
  
  directorate <- fd %>%
    group_by(area, directorate) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  divisions <- fd %>%
    group_by(area, directorate, division) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  grade <- fd %>%
    group_by(grade) %>%
    summarize(cop_prc = round(mean(cop)*100,2),
              qsig_prc = round(mean(qsig)*100,2))
  
  breakdowns <- list(group = group,
                     directorate = directorate,
                     divisions = divisions,
                     grade = grade)
  
}

breakdown_list <- breakdowns(fd)
#nrow takes total number of rows in fd, where values in cop/qsig columns = 1 
#the mean works in the breakdown function but only because it is a binary value 
#would be good to improve with a loop if possible
