
################################
##        Training Data      ##
################################

QSIG <- courses_list[["QSIG"]] %>% rename(qsig_complete = course)
COP <- courses_list[["CoP"]] %>% rename(cop_complete = course)

# combining qsig and cop to create user completion status 
elearning_all <- merge(QSIG, COP, by = "email", all = TRUE) %>% 
  select(email, qsig_complete, cop_complete)

################################
##            merging         ##
################################

# get paths to the staff counts data
staff_counts <- get_staff_counts()

# attach staff counts to elearning data 
ons_training_all <- merge(staff_counts, 
                          elearning_all, 
                          all.x = TRUE, 
                          by = "email") %>% 
  replace_na(list(cop_complete = 0, qsig_complete = 0))

################################
##          ONS  metrics      ##
################################

# calculate completion rates for qsig & cop
cop_prc <- round(sum(ons_training_all$cop_complete)/nrow(ons_training_all)*100,2)
qsig_prc <- round(sum(ons_training_all$qsig_complete)/nrow(ons_training_all)*100,2)

# combine results into one data frame and provide the month name
total_completion_rate <- data.frame("month" = format(cut_off_date, "%B %Y"),
                                    "cop" = paste0(cop_prc, "%"), 
                                    "qsig" = paste0(qsig_prc, "%")
                                    )


################################
##    Breakdowns              ##
################################

#' Calculate breakdowns by unit.
#'
#' @return list of data frames grouped by area, division etc.
#' @export
#'
#' @examples

calculate_breakdowns <- function(){
  
  # Create empty list to populate as we go using a loop
  breakdown_list <- list()
  
  # Handling grade separately for clarity
  breakdown_list[["grade"]] <- ons_training_all %>%
    group_by(grade) %>%
    summarize(cop_prc = round(mean(cop_complete)*100, 2),
              qsig_prc = round(mean(qsig_complete)*100, 2))
  
  # Loop allows us to avoid duplicating code
  # first group by all units e.g (area, directorate, division) and summarise,
  # then remove the last element from the list e.g. (area, directorate)
  # Repeat until list is empty.
  units = c("area", "directorate", "division")
  while (length(units) > 0) {
    
    # breakdown_name is the name we're going to give to divs in the next part 
    # of the loop below. we get this by taking the lowest aggregation level 
    # and using that as the data frame's unique name
    # e.g. if we're currently grouping by (area,division)
    # then we will name it division
    breakdown_name <- tail(units, 1)
    
    divs = ons_training_all %>%
      group_by_at(units) %>%
      summarize(cop_prc = round(mean(cop_complete)*100, 2),
                qsig_prc = round(mean(qsig_complete)*100, 2))
    
    # Attach names assigned in 'breakdown_name' to each 'divs' output
    # e.g. area, directorate -> directorate
    breakdown_list[[breakdown_name]] <- divs
    
    # Remove one aggregation level per iteration
    # e.g. c("area", "directorate", "division") -> c("area", "directorate")
    units <- head(units, -1)
  }
  
  return(breakdown_list)
}

breakdown_list <- calculate_breakdowns()

################################
##      Final Export          ##
################################

# create a list with all breakdowns
export <- list("ONS_metrics" = total_completion_rate,
               "by_area" = breakdown_list[["area"]],
               "by_directorate" = breakdown_list[["directorate"]],
               "by_division" = breakdown_list[["division"]],
               "by_grade" = breakdown_list[["grade"]],
               "all_data" = ons_training_all)

# Create name of file
# e.g., path\\to\\SP\\2023_9_elearning_metrics.xlsx
filepath <- paste0(Sys.getenv("USERPROFILE"),
                   (config::get())[["outputs_loc"]], 
                   lubridate::year(cut_off_date),
                   "_",
                   lubridate::month(cut_off_date), 
                   "_elearning_metrics.xlsx")

# export file to SP 
writexl::write_xlsx(export, filepath)



