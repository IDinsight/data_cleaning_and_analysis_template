
# 0. Overview
This template and guidance describes how to use git and github for version control to make collaboration on complicated coding tasks easier. In the past, we have used dropbox to collaborate on do files. This approach works Ok for simple coding but gets messy for more complicated tasks because a) you can't easily tell what has changed in a do file or who made the change, b) you can't easily experiment with code changes (i.e. if you want to test out a new approach you need to create a new do file or else use the main do file and remember to roll back any changes if things don't work out), and c) if two people are working on a file at the same time (or one person forgets to save and close a file) you can get conflicted copies of a file on Dropbox. Git takes some up front time to learn but makes collaborating on files much easier. In addition, this approach makes it much easier to use tools like Claude Code for coding. 

# 1. High-level overview of this approach
With the approach outlined here, all data still lives on Dropbox but all do files (and R and python scripts if you are using them) are managed by git and github.

Staff make changes to code locally on their laptop. Once they get things working locally, they "push" (i.e. share) these changes to github. Another staff member reviews these changes and, if they look Ok, "merges" them in with the rest of the codebase. Other staff members then "pull" (i.e. copy) these code changes to their local laptops. 


# 2. When to use this template and approach
We recommend using this template and approach for a typical data cleaning and analysis pipeline where a team of one associate, one manager, and one economist is cleaning and analyzing data from a single survey. For simpler pipelines where the associate is doing the vast majority of the work, the traditional approach of putting all the do files on dropbox is fine. For more complex pipelines, we recommend using the [IPA Stata template](https://github.com/PovertyAction/ipa-stata-template) and something like statacons to orchestrate the various do files. 

# 3. One-time setup
The following tasks must be performed once prior to using this template.  You only need to do them once. 

## Install git and the github command line tools

## Create a github account and getting added to the IDinsight organization

## Configure git

## Learn git basics



# 4. Pipeline set up tasks
The following tasks must be performed once for each new data cleaning and analysis pipeline. 

1.  **Create a new repo from this template** -
Go to the repo [webpage](https://github.com/IDinsight/data_cleaning_and_analysis_template) and click on "Use this template" and then "Create a new repository. Set the owner to be "IDinsight", choose a name for the repository; add a description; and set the visibility to "private"
2. **Clone the repo** 
3. **Add symlink for dropbox data folder**

# 5. Recommended git workflow

- we recommend using the feature branch workflow
- describe how to set this up