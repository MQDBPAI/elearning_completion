
################################
##        Training Data      ##
################################

QSIG <- courses_list[["QSIG"]] %>% rename(QSIG = course)
COP <- courses_list[["CoP"]] %>% rename( COP = course)



training_df <- merge(QSIG, COP, by = "email", all = TRUE) %>% 
  select(email, QSIG, COP)


rm(courses_list,
   QSIG,
   COP)




################################
##            merging         ##
################################


ONS_training_all <- merge(staff, 
                          training_df, 
                          all.x = TRUE, 
                          by = "email") %>% 
  replace_na(list(COP = 0, QSIG = 0))


rm(staff,
   training_df)


################################
##          ONS  metrics      ##
################################



cop_prc <- round(sum(ONS_training_all$COP)/nrow(ONS_training_all)*100,2)

qsig_prc <- round(sum(ONS_training_all$QSIG)/nrow(ONS_training_all)*100,2)

all_ONS <- data.frame("month" = paste0("month_", lubridate::month(cut_off_date)),
                      "cop" = paste0(cop_prc, "%"), 
                      "qsig" = paste0(qsig_prc, "%")
                      )

rm(cop_prc,
   qsig_prc)




################################
##    Breakdowns              ##
################################


breakdowning <- function(){
  
  group <-ONS_training_all %>%
    group_by(area) %>%
    summarize(cop_prc = round(mean(COP)*100,2),
              qsig_prc = round(mean(QSIG)*100,2))
  
  directorate <- ONS_training_all %>%
    group_by(area, directorate) %>%
    summarize(cop_prc = round(mean(COP)*100,2),
              qsig_prc = round(mean(QSIG)*100,2))
  
  divisions <- ONS_training_all %>%
    group_by(area, directorate, division) %>%
    summarize(cop_prc = round(mean(COP)*100,2),
              qsig_prc = round(mean(QSIG)*100,2))
  
  grade <- ONS_training_all %>%
    group_by(grade) %>%
    summarize(cop_prc = round(mean(COP)*100,2),
              qsig_prc = round(mean(QSIG)*100,2))
  
  breakdowns <- list(group = group,
                     directorate = directorate,
                     divisions = divisions,
                     grade = grade)
  
}

breakdown_list <- breakdowning()

rm(breakdowning)


################################
##      Final Export          ##
################################

export <- list("ONS_metrics" = all_ONS,
               "by_group" = breakdown_list[["group"]],
               "by_directorate" = breakdown_list[["directorate"]],
               "by_divisions" = breakdown_list[["divisions"]],
               "by_grade" = breakdown_list[["grade"]],
               "all_data" = ONS_training_all)

writexl::write_xlsx(export, paste0(Sys.getenv("USERPROFILE"),
                                  (config::get())[["outputs_loc"]], 
                                   lubridate::year(cut_off_date),
                                   "_",
                                   lubridate::month(cut_off_date), 
                                   "_elearning_metrics_friday.xlsx"))
                                              



