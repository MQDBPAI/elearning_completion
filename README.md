# E-learning_completion rates
Authors: Margarita Tsakiridou, Holly Donnell, DQHub


The code is combining the logs from the Learning Hub Platform and staff counts data
to produce completion rate metrics. 

## Completion rates calculations

The completion rate is calculated as the quotient of:

- total employees that completed the training up to end of the reporting month
- total employees in a given month.

Note that the completion rate is thus a 'snapshot'.


## Code set up
Before running the code, please read through the notes below.

### Inputs
First Download both the QSIG and COP logs from Learning Hub and save in the 
**E-learning_logs** folder in your SharePoint (see logs_loc filepath in config.yml).
Make sure the file name includes today's date, in the format: YYYY-MM-DD.
The code is configured to pick the most recent files.

Open the config.yml file and change the value of the date field to the **last day of the previous month** for the snapshot you need. 
E.g., I need the September snapshot so I set the date to be 2023-09-30
Make sure you use Ctrl + S to save the date before running the code.

In order for the code to run you need to sync the SharePoint folders below
to your personal file explorer:
1. [Quality_champions_DL_and_QIP_tracking](https://officenationalstatistics.sharepoint.com/sites/beprasim/Quality%20Improvement%20Plans/Forms/AllItems.aspx?id=%2Fsites%2Fbeprasim%2FQuality%20Improvement%20Plans%2FQuality%5Fchampions%5FDL%5Fand%5FQIP%5Ftracking&viewid=b520aa1e%2De6d5%2D40ec%2D873d%2D464791b272c5) - we only need the staff counts folder from in there, but because we probably all have synced this folder for the champions Python DL, it would be good to stay consistent.
2. [E-learning metrics](https://officenationalstatistics.sharepoint.com/sites/beprasim/Metrics%20and%20Information/Forms/AllItems.aspx?newTargetListUrl=%2Fsites%2Fbeprasim%2FMetrics%20and%20Information&viewpath=%2Fsites%2Fbeprasim%2FMetrics%20and%20Information%2FForms%2FAllItems%2Easpx&id=%2Fsites%2Fbeprasim%2FMetrics%20and%20Information%2FE%2Dlearning%20metrics%2F1%2EE%2Dlearning%5Flogs&viewid=6f156f8a%2D6331%2D4ee1%2D843c%2Da9efa47124d5)

To do this, locate the folders above in your SharePoint and
click the **Sync** button, see screenshot below. Note that is it very important to sync at exactly the correct level specified, otherwise the code will fail.

![Syncing_folders](https://github.com/MQDBPAI/elearning_completion/assets/116284001/77dede89-de68-4e37-8f09-98f322312106)

If you are unable to access the staff counts data in your SharePoint folder 
for some reason, the code will still run on a backup file from your local repo. 
So, in this case, you will need to download the latest staff counts excel file
and save it within your local repo before running the code. This is not needed
in a usual run of the code, when you have access to the staff counts from the 
Staff_counts_for_use_in_pipelines folder.

**Important Note**, if you do run the code using staff counts in your local 
repo and make any changes that you wish to commit back to Git, it is 
**very important** you use certain commands to ensure you are not publishing 
those staff counts to this public online Git repo.

The git commands you will want to use are:
```
git status
git add -u
git commit -m "commit message"
git push -u
```
Make sure you use **'-u'** where noted above, otherwise you will publish the
staff counts data to this public Git repo.


### Outputs
It produces a workbook on SharePoint with completion rates as a snapshot
of the month supplied with breakdowns per organisational structure and grade.


## Run the code

Now you are set to run the code, clone the repo locally and open 
the main.R script to follow the instructions from there.


## QA the code

- Inspect the exports and ensure that columns and data look sensible
- In your local directory folder you will find a log_YYYY-MM-DD.txt file with
'today's' date. This shows the 3 input files used and the cut off date used.
Inspect to ensure the correct files have been picked up.
