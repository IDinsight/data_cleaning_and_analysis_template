# Git, GitHub, and Gemini CLI Workshop

## Overview

AI coding agents are amazing. They can help you move faster, debug issues, and handle repetitive coding tasks with much less effort.

To use AI coding agents safely and effectively on a group project, you need version control. In practice, that means using Git so everyone can work in parallel, review changes, and avoid breaking shared work.

Git is a bit confusing at first, but AI makes it much easier to use. If you stick to a clear workflow and ask the AI for help when you get stuck, you can be productive quickly without becoming a Git expert on day one.

## Intro to Git

Think of Git as a high-tech "Undo" button for your projects. It is the industry standard for version control, ensuring you never lose your work. git has...

* **Version Tracking**: It keeps a complete history of your project so you can jump back to any previous state if something breaks.
* **Safe Snapshots**: Instead of saving multiple file copies, you take "commits" that capture your entire project at a specific moment.
* **Branching**: You can create "side paths" to test new ideas safely without affecting your main, working version.
* **Team Syncing**: It allows multiple people to work on the same files at once and merges their changes together automatically.

github is a cloud-based platform for hosting git repositories.

## Git basics, part 1

Git takes some time to get used to. The best way to learn git is by doing but it is useful to first understand some basic concepts:

*   **Repository:** The folder with all of your files (and the complete history of all the changes you have made). The .git sub-folder contains all data required for git to do its thing
*   **Commit:** A snapshot of your repository at a specific point in time. 
*   **Branch:** Kind of like a "parellel universe" for your code where you can test out new ideas

## Git basics, part 2

If you're not used to working with version control, you probably think of the contents of a folder that you see when you open Mac Finder or Windows Explorer as the one and only truth. With git, what you see in Find or Explorer is called the working directory and is just the version of files that you are currently working on. 


![Git areas diagram (working directory, staging area, git directory)](https://git-scm.com/book/en/v2/images/areas.png)

Source: [Pro Git Book - Recording Changes to the Repository](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository)

## The git feature branch workflow

There are a lot of different ways to use git to collaborate. For our work, we recommend the feature branch workflow. That is what we will walk through in this workshop. With the feature branch workflow:

* You never work directly on the `main` branch.
* New work happens on a short-lived feature branch (for example, `test_name`). Once you are confident in your changes, you ask the project lead to review and merge into the `main` branch
* The basic cycle is: `branch -> code -> commit -> push -> pull request -> merge`.

Why this matters: it lets people work in parallel, makes review easier, and lowers the risk of breaking shared code.

## If you get lost, ask one of the AIs

Git can be very confusing but you don't need to be an expert to get started and use it effectively. Stick to the recommended workflow and if something goes wrong ask one of the AIs (or just take XKCD's advice)

[![alt text](https://imgs.xkcd.com/comics/git.png)]


## Step 0: Workshop pre-work

If you haven't already done so, please complete the following tasks. For more details, refer to [README one-time setup](README.md#3-one-time-setup).

* Install Git and GitHub CLI (`gh`) on your machine.
* Create/configure your GitHub account (including 2FA), get added to the org, and run `gh auth login`.
* Configure Git identity (`user.name` and `user.email`), install Gemini CLI, and create a local `code` folder for repositories.
* (Optional but recommend) Install VS Code


## Step 1: Terminal crash course

Git is a command-line tool, so you need to be comfortable with the basics of using a terminal. On Mac, open the built-in **Terminal** app (search for "Terminal" in Spotlight). On Windows, open **Git Bash** (installed with Git for Windows).

A terminal lets you interact with your computer by typing commands instead of clicking. Here are the essential commands you need:

| Command | What it does | Example |
|---|---|---|
| `pwd` | Print working directory — shows where you are | `pwd` → `/Users/jane/Documents/code` |
| `ls` | List files and folders in the current directory | `ls` → `README.md  data/  scripts/` |
| `cd <folder>` | Change directory — move into a folder | `cd Documents` |
| `cd ..` | Move up one level | `cd ..` (goes from `code/` back to `Documents/`) |
| `cd ~` | Go to your home directory | `cd ~` → `/Users/jane` |

**Try it now:**

1. Open Terminal (Mac) or Git Bash (Windows).
2. Type `pwd` and press Enter to see where you are.
3. Type `ls` to see what files and folders are here.
4. Type `cd Documents/code` to navigate to your code folder (adjust the path if yours is different).
5. Type `pwd` again to confirm you're in the right place.

That's all you need to get started. You'll pick up more as you go, and you can always ask an AI for help with terminal commands.

## Step 2: Clone the Repo

With git and github, the first step in a new project is to create a new repo. You can do this either by creating the folder on your laptop and then creating a repo on github or by "cloning" a remote repo from github. We will start by cloning a sample repo.


1.  **Go to Your Code Folder First:**
    Make sure you are in `Documents/code` (or whatever folder you created to store all your code projects).
    ```bash
    cd ~/Documents/code
    pwd
    ```
    This moves your terminal into your main code directory and prints your current location so you can verify you are in the right place before cloning.
    The `pwd` output should end with `Documents/code` (or your chosen code folder path).

2.  **Clone the Workshop Repository:**
    ```bash
    git clone https://github.com/dougj892/workshop_test_repo
    ```
    This downloads a full local copy of the GitHub repository, including files, branches, and commit history.

    > **VS Code alternative:** Open the Command Palette (`Cmd+Shift+P` on Mac / `Ctrl+Shift+P` on Windows), type "Git: Clone", paste the URL `https://github.com/dougj892/workshop_test_repo`, and choose your `Documents/code` folder as the destination.

3.  **cd into the Repository Folder:**
    ```bash
    cd workshop_test_repo
    pwd
    ```
    This enters the cloned project folder and prints the path so you can confirm you are now inside the workshop repository.
    The `pwd` output should end with `workshop_test_repo`.

    > **VS Code alternative:** After cloning, VS Code will ask if you want to open the cloned repository. Click "Open".

## Step 3: Build and Ship a Small Feature

In this scenario, a participant will create a new branch, make a small change, commit it, push it to GitHub, and create a pull request.

1.  **Create and Switch to a New Branch:**
    ```bash
    git switch -c test_name
    ```
    This creates a new branch named `test_name` and immediately switches your working directory to it.
    (Replace `name` with your name. When actually coding, your branch names should be more descriptive but for this workshop this is fine.)

    > **VS Code alternative:** Click the branch name in the bottom-left corner of the VS Code window (it will say "main"). Select "Create new branch…", type `test_name`, and press Enter.

2.  **Make a Change:**
    Add some content to the top of `README.md`. It doesn't what you add, but you should add it to the top of the file. (This will ensure that this change conflicts with the change that other participants are making.)

3.  **Stage and Commit the Change:**
    ```bash
    git add .
    git commit -m "feat: Add new greeting message"
    ```
    `git add .` stages your current file changes, and `git commit` saves that staged snapshot to your local Git history with a message.
    (The commit message should clearly describe your change.)

    > **VS Code alternative:** Open the Source Control panel (click the branch icon in the left sidebar). You'll see your changed files listed under "Changes". Click the **+** icon next to each file (or next to "Changes" to stage all) to stage them. Type your commit message in the text box at the top and click the **Commit** button.

4.  **Push the Branch to GitHub:**
    ```bash
    git push -u origin test_name
    ```
    This uploads your branch to GitHub and sets its upstream tracking branch so later pushes can use just `git push`.
    (Again, replace `name` with your name. Note that we have to type this full command only once for each new branch we create. After that, we can just type `git push` and git will know what to do.)

    > **VS Code alternative:** After committing, click the **"Publish Branch"** button that appears in the Source Control panel (or click the cloud icon in the bottom-left status bar). For subsequent pushes, this button will say **"Sync Changes"** instead.

5.  **Create a Pull Request:**
    Navigate to the GitHub repository in your browser. GitHub will usually prompt you to create a pull request from your newly pushed branch. Fill in the details and create the PR.

6.  **Review and Merge (Doug to do this):**
    I will review the PR, potentially suggest changes, and then approve and merge it into the `main` branch.

## Step 4: Handling a Merge Conflict

When we tried to merge in the second pull request we got an error saying that the branch has conflicts that must be resolved. This is because the second participant was updating the same section of `README.md` as the first participant. We could resolve these on github, but a better solution is for the second participant to resolve the conflicts on their own.

1.  **Switch to Main and Pull Latest Changes:**
    *(Simulating another team member pushing changes to `main`)*
    ```bash
    git switch main
    git pull origin main
    ```
    This checks out `main` and downloads then merges the newest commits from the remote `main` branch into your local `main`. If you were the participant whose pull request I approved
    *(At this point, the facilitator or another participant would have pushed a conflicting change to `main`.)*

    > **VS Code alternative:** Click the branch name in the bottom-left corner and select "main" to switch branches. Then click the **Sync Changes** button (circular arrows icon in the bottom status bar) to pull the latest changes.

2.  **Switch Back to Feature Branch:**
    ```bash
    git switch test_name
    ```
    This returns you to your feature branch so you can bring in the latest `main` changes and resolve conflicts there.

    > **VS Code alternative:** Click the branch name in the bottom-left corner and select your feature branch (`test_name`).

3.  **Merge `main` into Your Feature Branch (and Resolve Conflicts):**
    ```bash
    git merge main
    ```
    This attempts to combine the latest commits from `main` into your current branch.
    If you get a conflict, run `git status` to see which files are conflicted, then open each conflicted file (likely `README.md`). Find the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), decide what final text to keep (your change, incoming change, or both), delete all marker lines, save the file, and run `git status` again to confirm the file is now ready to stage. This is a lot easier in a code editor like VS Code, but it is useful to do this using a simple text editor the first time you do it so you understand what is happening under the hood when you use a more sophisticated tool

    > **VS Code alternative:** Open the Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`), type "Git: Merge Branch…", and select "main". If there are conflicts, VS Code will highlight them in the editor with colored blocks and give you buttons to **Accept Current Change**, **Accept Incoming Change**, **Accept Both Changes**, or **Compare Changes** — making conflicts much easier to resolve.

4.  **Stage and Commit the Resolved Conflicts:**
    After resolving conflicts, mark the file(s) as resolved and commit:
    ```bash
    git add .
    git commit -m "Merge main into feature/update-contact and resolve conflicts"
    ```
    These commands stage your conflict-resolution edits and create a merge commit that records the resolved state.

    > **VS Code alternative:** After resolving all conflicts, the files will appear in the Source Control panel. Click **+** to stage them, type a commit message, and click **Commit**.

5.  **Push the Feature Branch:**
    ```bash
    git push
    ```
    Since you already told git where you want to push the branch, all you need to do now is type `git push`. You also don't need to update the pull request.

    > **VS Code alternative:** Click the **Sync Changes** button in the bottom status bar.

## What are AI coding agents?

AI coding agents are tools that can read your codebase, run commands, propose edits, and help you complete software tasks faster. The table below summarizes the state of the market as of Feb 2026

| Agent | Cost | Quality |
|---|---|---|
| Codex | Medium | High |
| Claude Code | Medium-High | High |
| Gemini CLI | Low-Medium | Medium-High |

## Important safety warning

<p style="color: #ff0000; font-size: 2.1em; font-weight: 800; line-height: 1.25;">
AI coding agents can do amazing things quickly, but unsupervised use can also cause real damage, including deleting files, breaking pipelines, leaking secrets, or introducing subtle bugs.
</p>

In the longer term, we will likely build stronger safeguards and defaults for users. For now, please watch what the coding agents are doing and don't auto-approve everything!

## Tips for using AI coding agents well

* Grant the minimum permissions needed; avoid broad filesystem and shell access unless required.
* Never expose secrets (API keys, credentials, private data) in prompts or unprotected files.
* Ask the agent to explain planned changes before major edits.
* Review every file diff yourself before accepting changes.
* Run tests and key scripts locally after agent edits.
* Make commits yourself with clear messages so you control what gets recorded.
* Use small, focused tasks instead of one giant prompt.
* If something looks risky or unclear, stop and ask for a safer alternative.

## AI coding agent test run

Let's test this out! We often use the Stata ado file ipacheckcorrections to make corrections to survey data. One issue that we often run into is that we accidentally insert leading or trailing spaces into the variables in our Excel config file which leads to an error. Let's fix this using an AI coding agent!

1. **Clone IPA's High-frequency checks repo**
   ```bash
   cd ~/Documents/code
   git clone https://github.com/PovertyAction/high-frequency-checks/tree/master
   ```


2. **Open Gemini CLI (or another AI coding agent) in the folder**
      ```bash
   cd ~/Documents/code/high-frequency-checks
   gemini
   ```

3. **Let the AI coding agent do it's magic**

   Just use plain language to describe the issue and what you want the coding agent to do. It helps if you tell it that the code you want to change is in the file @ipacheckcorrections.ado but when I used Claude Code it figured this out on its own.  If you want to test out the changes, open the ado file "ipacheckcorrections.ado" and click "do" and then call ipacheckcorrections from another Stata do file. 
