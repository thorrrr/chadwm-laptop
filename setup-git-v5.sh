#!/bin/bash

# Function to check if the current directory is a Git repository or initialize a new one
check_git_repository() {
    if [ ! -d .git ]; then
        git init
    fi
}

# Set your GitHub username and email
github_username="thorrrr"
github_email="dalestorage1@gmail.com"

# Read GitHub token from a secure location
github_token=$(cat ~/.github_token)

# Function to prompt user for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    read -p "$prompt [$default]: " result
    result="${result:-$default}"
    echo "$result"
}

# Check if the current directory is a Git repository or initialize a new one
check_git_repository

# Prompt user for project name
project=$(basename "$(pwd)")

# Prompt user for GitHub repository name
github_repo=$(prompt_with_default "Enter GitHub repository name" "$project")

# Construct GitHub repository URL
github_repo_url="git@github.com:$github_username/$github_repo.git"

# Check if the repository already exists
if ! curl -s "https://api.github.com/repos/$github_username/$github_repo" | grep -q "Not Found"; then
    echo "Repository $github_repo already exists."
else
    # Create a new repository using the GitHub API
    curl -X POST -H "Authorization: token $github_token" -d '{"name":"'$github_repo'"}' "https://api.github.com/user/repos"
    echo "Repository $github_repo created."
fi

# Add placeholder file (e.g., README.md)
echo "# $project" >> README.md
git add README.md
git commit -m "Initial commit"

# Add GitHub remote and push changes to main branch
git remote add origin "$github_repo_url"
git branch -M main
git push -u origin main

echo "-----------------------------------------------------------------------------
This project is configured for GitHub repository:
User: $github_username
Repository: $github_repo
URL: $github_repo_url
-----------------------------------------------------------------------------
Everything set. Happy coding!
################################################################
###################    T H E   E N D      ######################
################################################################"
