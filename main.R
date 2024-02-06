
# Now you are set to run the code from the instructions set out in the 
# README.md file. Run each of the following lines:

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
