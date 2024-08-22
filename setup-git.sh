#!/bin/bash

# Read GitHub username and email from a config file
config_file="$HOME/.github_config"
if [ ! -f "$config_file" ]; then
    echo "GitHub config file not found. Please create $config_file with the following content:"
    echo "GITHUB_USERNAME=your_username"
    echo "GITHUB_EMAIL=your_email@example.com"
    exit 1
fi

source "$config_file"

# Check SSH key availability
check_ssh_key() {
    if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "SSH key for GitHub not found or not working."
        echo "Please ensure you have set up an SSH key for this machine and added it to your GitHub account."
        echo "You may need to create an SSH config file (~/.ssh/config) to specify the correct key for github.com"
        exit 1
    fi
}

# Function to check if the current directory is a Git repository or initialize a new one
check_git_repository() {
    if [ ! -d .git ]; then
        git init
        git config user.name "$GITHUB_USERNAME"
        git config user.email "$GITHUB_EMAIL"
    fi
}

# Function to prompt user for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# Check SSH key availability
check_ssh_key

# Check if the current directory is a Git repository or initialize a new one
check_git_repository

# Get project name from current directory
project=$(basename "$(pwd)")

# Prompt user for GitHub repository name
github_repo=$(prompt_with_default "Enter GitHub repository name" "$project")

# Construct GitHub repository URL (using SSH)
github_repo_url="git@github.com:$GITHUB_USERNAME/$github_repo.git"

# Check if the repository already exists
if ! git ls-remote --exit-code --heads $github_repo_url &>/dev/null; then
    # Create a new repository using the GitHub CLI (if installed)
    if command -v gh &> /dev/null; then
        gh repo create "$github_repo" --private --yes
        echo "Private repository $github_repo created."
    else
        echo "GitHub CLI not found. Please create a private repository manually on GitHub."
        echo "Visit: https://github.com/new"
        echo "Repository name: $github_repo"
        echo "Make sure to set it as Private"
        read -p "Press Enter after creating the repository..."
    fi
else
    echo "Repository $github_repo already exists."
fi

# Create README.md if it doesn't exist
if [ ! -f README.md ]; then
    echo "# $github_repo" > README.md
    git add README.md
    git commit -m "Initial commit: Add README.md"
fi

# Add all files in the current directory
git add .

# Commit changes if there are any staged changes
if ! git diff --staged --quiet; then
    git commit -m "Initial commit"
fi

# Add or update GitHub remote
if git remote | grep -q '^origin$'; then
    git remote set-url origin "$github_repo_url"
else
    git remote add origin "$github_repo_url"
fi

git branch -M main
git push -u origin main

# Check if the push was successful
if [ $? -eq 0 ]; then
    echo "Changes pushed to private remote repository."
else
    echo "Failed to push changes to remote repository."
    exit 1
fi

echo "-----------------------------------------------------------------------------"
echo "This project is configured for private GitHub repository:"
echo "User: $GITHUB_USERNAME"
echo "Repository: $github_repo"
echo "URL: $github_repo_url"
echo "-----------------------------------------------------------------------------"
echo "Everything set. Happy coding!"