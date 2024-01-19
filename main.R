################################################################################ 
#                                                                              #
#                                                                              #
# Title: E-learning Completion Rates for Mandatory Training                    #
# Authors: Margarita Tsakiridou, Holly Donnell, DQHub                          #
# Date: 04/01/2023                                                             #
#                                                                              #
# Desk notes for this project can be found at the associated SharePoint (SP)   #
# folder                                                                       #
#                                                                              #
# Inputs                                                                       #
# The code to run needs access to the                                          #
# 1) People Analytics Folders                                                  #
# 2) Most up-to-date Learning Hub logs                                         #
#                                                                              #
#                                                                              #
# Outputs                                                                      #
# It produces a workbook on SharePoint with completion rates as a snapshot     #
# of the month supplied with breakdowns per organizational structure and grade #
#                                                                              #  
#                                                                              #
################################################################################

# First Download both the QSIG and COP logs from Learning Hub and save in the 
#"Best Practice Assurance and Improvement - E-learning metrics\1.E-learning_logs\1.E-learning_logs" 
# SharePoint folder. Make sure you give them today's date. The code is 
# configured to pick the most recent files.

# Open the config.yml file and change the value of the date field to the last 
# day of the previous month for the snapshot you need. E.g., I need the September 
# snapshot so I set the date to be 2023-09-30

# Now you are set to run the code. Run each of the following lines:

# First call the tidyverse package

library(tidyverse)


# The following script does three things:
# defines the locations to read in and output the data needed 
# provides a function for reading and formatting in QSIG & COP data
# provides a function for reading and formatting the staff counts data 

source("./scripts/1.locs set up.R", echo=FALSE)

# Here we load the data. After we run this script we should have a 
# 'courses_list' list  with two data frames (1 for each course) and the staff
# data frame. We will then be ready to link the data and obtain the metrics

source("./scripts/2. Data loading.R", echo=FALSE)

# The final script merges the QSIG & COP data with the staff counts data, creates 
# the various breakdowns and stores them in a list which is exported to SP

source("./scripts/3. data_linking.R", echo = FALSE)
