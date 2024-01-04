################################################################################ 
#                                                                              #
#                                                                              #
# Title: E-learning Completion Rates for Mandatory Training                    #
# Authors: Margarita Tsakiridou, Holly Donnell, DQHub                          #
# Date: 04/01/2023                                                             #
#                                                                              #
# Desk notes for this project can be found at the associated SharePoint folder #
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

# Run each of the following lines:

# First call the tidyverse package

library(tidyverse)


# The following script stores in our environment the locations from which it
# will pull the data

source("./scripts/1.locs set up.R", echo=FALSE)

# Here we load the data. After we run this script we should have a 
# 'courses_list' list  with two data frames (1 for each course) and the staff
# data frame. We are now ready  to link the data and obtain the metrics

source("./scripts/2. Data loading.R", echo=FALSE)


# The final script merges the training data with the ONS staff counts and
# stores them in a list which is exported to SharePoint

source("./scripts/3. data_linking.R", echo = FALSE)
