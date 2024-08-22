#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error: $1" >&2
    exit 1
}

# Get current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD) || handle_error "Failed to get current branch name"
echo "Working on branch: $current_branch"

# Check for newer files online
echo "Checking for newer files online first..."
git pull || handle_error "Failed to pull from remote"

# Add all changes to staging area
git add --all . || handle_error "Failed to add changes to staging area"

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    # Prompt user for commit message
    echo "Enter your commit message (press Enter for default):"
    read -r input
    commit_message=${input:-"Auto commit"}
    
    # Commit changes
    git commit -m "$commit_message" || handle_error "Failed to commit changes"
fi

# Push changes to remote repository (default choice is "Y")
read -p "Do you want to push changes to remote repository? (Y/n): " confirm
confirm=${confirm:-"Y"}  # Set default choice to "Y"
if [[ $confirm =~ ^[Yy]$ ]]; then
    git push origin "$current_branch" || handle_error "Failed to push to remote"
    echo "Changes pushed to remote repository."
else
    echo "Changes were not pushed to remote repository."
fi