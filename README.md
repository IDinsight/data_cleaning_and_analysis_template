
# 0. Overview
This template and guidance describes how to use git and github for version control to make collaboration on complicated coding tasks easier. In the past, we have used dropbox to collaborate on do files. This approach works Ok for simple coding but gets messy for more complicated tasks because a) you can't easily tell what has changed in a do file or who made the change, b) you can't easily experiment with code changes (i.e. if you want to test out a new approach you need to create a new do file or else use the main do file and remember to roll back any changes if things don't work out), and c) if two people are working on a file at the same time (or one person forgets to save and close a file) you can get conflicted copies of a file on Dropbox. Git takes some up front time to learn but makes collaborating on files much easier. In addition, this approach makes it much easier to use tools like Claude Code for coding. 

# 1. High-level overview of this approach
With the approach outlined here, all data still lives on Dropbox but all do files (and R and python scripts if you are using them) are managed by git and github.

Staff make changes to code locally on their laptop. Once they get things working locally, they "push" (i.e. share) these changes to github. Another staff member reviews these changes and, if they look Ok, "merges" them in with the rest of the codebase. Other staff members then "pull" (i.e. copy) these code changes to their local laptops. 


# 2. When to use this template and approach
We recommend using this template and approach for a typical data cleaning and analysis pipeline where a team of one associate, one manager, and one economist is cleaning and analyzing data from a single survey. For simpler pipelines where the associate is doing the vast majority of the work, the traditional approach of putting all the do files on dropbox is fine. For more complex pipelines, we recommend using the [IPA Stata template](https://github.com/PovertyAction/ipa-stata-template) and something like statacons to orchestrate the various do files. 

# 3. One-time setup
The following tasks must be performed once prior to using this template.  You only need to do them once. 

## Install git and the GitHub command line tools

**Mac:**
1. Open Terminal and run `git --version`. If git isn't installed, you'll be prompted to install the Xcode Command Line Tools - follow the prompts.
2. Install the GitHub CLI by first installing [Homebrew](https://brew.sh/) if you don't have it, then running:
   ```
   brew install gh
   ```

**Windows:**
1. Download and install [Git for Windows](https://git-scm.com/download/win). Use the default settings during installation.
2. Download and install the [GitHub CLI](https://cli.github.com/).

## Create a GitHub account and get added to the IDinsight organization

1. Go to [github.com](https://github.com) and create a free account if you don't already have one.
2. Ask your manager or a current member of the IDinsight GitHub organization to add you. They can do this by going to the [IDinsight organization settings](https://github.com/orgs/IDinsight/people) and clicking "Invite member."

## Configure git

Open Terminal (Mac) or Git Bash (Windows) and run the following commands, replacing the placeholder text with your information:

```
git config --global user.name "Your Name"
git config --global user.email "your.email@idinsight.org"
```

Then authenticate with GitHub by running:
```
gh auth login
```
Follow the prompts, selecting "GitHub.com", "HTTPS", and "Login with a web browser".

## Learn git basics

The best way to learn git is to use ChatGPT with "study and learn" mode turned on and ask it to walk you through a hands-on intro to git and the feature branch workflow. It will guide you through the concepts interactively and answer your questions as you go.

If you prefer self-directed resources, we also recommend:
- [GitHub's Git Handbook](https://guides.github.com/introduction/git-handbook/) - A 10-minute read covering the basics
- [Git Basics Video](https://git-scm.com/video/what-is-version-control) - Short video introduction
- Practice with [Learn Git Branching](https://learngitbranching.js.org/) - An interactive tutorial

Key concepts to understand:
- **Repository (repo)**: A folder containing your code and its entire version history
- **Commit**: A snapshot of your code at a point in time
- **Branch**: A parallel version of your code where you can make changes without affecting the main codebase
- **Push**: Upload your local commits to GitHub
- **Pull**: Download commits from GitHub to your local machine
- **Merge**: Combine changes from one branch into another



# 4. Pipeline set up tasks
The following tasks must be performed once for each new data cleaning and analysis pipeline. 

1.  **Create a new repo from this template** -
Go to the repo [webpage](https://github.com/IDinsight/data_cleaning_and_analysis_template) and click on "Use this template" and then "Create a new repository. Set the owner to be "IDinsight", choose a name for the repository; add a description; and set the visibility to "private"
2. **Clone the repo** - Open Terminal (Mac) or Git Bash (Windows), navigate to where you want to store the code, and run:
   ```
   gh repo clone IDinsight/<repo-name>
   ```
   Replace `<repo-name>` with the name of the repository you created. This creates a local copy of the repository on your computer.

3. **Add symlink for Dropbox data folder** - Since data lives on Dropbox but code is managed by git, we use a symbolic link (symlink) to connect them. This lets your do files reference a `Data` folder that actually points to the Dropbox location.

   **Mac:**
   ```
   cd <repo-name>
   ln -s "/Users/<username>/Dropbox/<project-folder>/Data" Data
   ```

   **Windows (run as Administrator):**
   ```
   cd <repo-name>
   mklink /D Data "C:\Users\<username>\Dropbox\<project-folder>\Data"
   ```

   Replace the paths with your actual Dropbox data folder location. The symlink (`Data`) is already in `.gitignore` so it won't be tracked by git.

# 5. Recommended git workflow

We recommend using the **feature branch workflow**. This means:
- The `main` branch always contains working, reviewed code
- All new work happens on separate "feature branches"
- Changes are reviewed via pull requests before being merged into `main`

## Day-to-day workflow

**Starting new work:**
1. Make sure you're on the main branch and have the latest code:
   ```
   git switch main
   git pull
   ```
2. Create a new branch for your work and switch to that branch:
   ```
   git switch -c descriptive-branch-name
   ```
   Use a short, descriptive name like `clean-baseline-data` or `fix-merge-duplicates`.

**As you work:**
1. Make changes to your do files and test that they run correctly.
2. When you reach a good stopping point, stage and commit your changes:
   ```
   git add -A
   git commit -m "Brief description of what you changed"
   ```
   Write commit messages that explain *what* changed and *why*.

**Sharing your work for review:**
1. Push your branch to GitHub:
   ```
   git push -u origin <branch-name>
   ```
2. Go to the repository on GitHub and create a **Pull Request** (PR). Add a description of your changes and request a review from your manager or teammate.

**Reviewing a pull request:**
1. Go to the repository on GitHub and click on the "Pull requests" tab.
2. Click on the PR you've been asked to review.
3. Click on the "Files changed" tab to see what code was added, modified, or removed. Lines highlighted in green are additions; lines in red are deletions.
4. Review the changes carefully:
   - Does the code do what it's supposed to do?
   - Is it clear and easy to understand?
   - Are there any obvious errors or potential issues?
5. To leave a comment on a specific line, hover over the line number and click the blue "+" icon. You can also highlight multiple lines to comment on a block of code.
6. When you're done reviewing, click the green "Review changes" button in the top right:
   - **Comment**: Leave general feedback without approving or requesting changes
   - **Approve**: The code looks good and is ready to merge
   - **Request changes**: There are issues that need to be addressed before merging
7. If you requested changes, the author will update their code and push new commits. You'll be notified to review again.

**After your PR is approved:**
1. Merge the PR on GitHub (using the "Squash and merge" option keeps history clean).
2. Switch back to main and pull the merged changes:
   ```
   git checkout main
   git pull
   ```
3. Delete your local feature branch (optional but keeps things tidy):
   ```
   git branch -d <branch-name>
   ```

## Tips
- **Commit often**: Small, frequent commits are easier to review and debug than large ones.
- **Pull before starting**: Always pull the latest `main` before creating a new branch.
- **Don't commit data**: Only commit code files. Data should stay on Dropbox.
- **Ask for help**: Git can be confusing at first. Don't hesitate to ask a colleague if you get stuck.