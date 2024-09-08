#!/bin/bash

# Change to the repository's root directory
cd "$(git rev-parse --show-toplevel)" || exit 1

# Check if Obsidian's Git plugin is currently running
if pgrep -f "obsidian" > /dev/null && git status --porcelain | grep -q '^.M'; then
    echo "Obsidian Git plugin may be running. Please wait a moment and try again."
    exit 1
fi

# Check if .gitignore is properly configured for Obsidian
if ! grep -q ".obsidian/workspace" .gitignore; then
    echo "Warning: Your .gitignore might not be properly configured for Obsidian."
    echo "Consider adding .obsidian/workspace and .obsidian/cache to your .gitignore."
fi

# Function to handle errors
handle_error() {
    echo "Error: $1" >&2
    exit 1
}

# Get current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD) || handle_error "Failed to get current branch name"
echo "Working on branch: $current_branch"

# Check for newer files online first
echo "Checking for newer files online first..."
git pull || handle_error "Failed to pull from remote"

# Stage modified and deleted files only
git add -u || handle_error "Failed to stage changes"

# Display staged changes and check for deletions
echo "Staged changes:"
git status

# Check if there are any deletions staged
if git diff --cached --name-only --diff-filter=D | grep '.'; then
    echo "Warning: The following files are marked for deletion:"
    git diff --cached --name-only --diff-filter=D
    read -p "Are you sure you want to commit these deletions? (y/N): " confirm_deletions
    if [[ ! $confirm_deletions =~ ^[Yy]$ ]]; then
        echo "Aborting commit due to deletion confirmation."
        git reset  # Unstage the deletions
        exit 1
    fi
fi

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    # Prompt user for commit message
    echo "Enter your commit message (press Enter for default: 'Auto commit'):"
    read -r input
    commit_message=${input:-"Auto commit"}

    # Commit changes
    git commit -m "$commit_message" || handle_error "Failed to commit changes"
fi

# Push changes to remote repository
read -p "Do you want to push changes to remote repository? (Y/n): " confirm
confirm=${confirm:-"Y"}  # Set default choice to "Y"
if [[ $confirm =~ ^[Yy]$ ]]; then
    git push origin "$current_branch" || handle_error "Failed to push to remote"
    echo "Changes pushed to remote repository."
else
    echo "Changes were not pushed to remote repository."
fi
