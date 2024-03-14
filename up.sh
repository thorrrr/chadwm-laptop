#!/bin/bash

# Check for newer files online
echo "Checking for newer files online first..."
git pull

# Add changes to staging area
git add --all .

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit."
else
    # Prompt user for commit message
    echo "Enter your commit message (press Enter for default):"
    read input
    commit_message=${input:-"Auto commit"}

    # Commit changes
    git commit -m "$commit_message"
fi

# Push changes to remote repository (default choice is "Y")
read -p "Do you want to push changes to remote repository? (Y/n): " confirm
confirm=${confirm:-"Y"}  # Set default choice to "Y"
if [[ $confirm =~ ^[Yy]$ ]]; then
    git push origin $(git rev-parse --abbrev-ref HEAD)
    echo "Changes pushed to remote repository."
else
    echo "Changes were not pushed to remote repository."
fi
