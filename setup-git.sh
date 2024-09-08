#!/bin/bash

# Change to the repository's root directory
cd "$(git rev-parse --show-toplevel)" || exit 1

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

# Function to set up .gitignore for Obsidian
setup_gitignore() {
    if [ ! -f .gitignore ]; then
        echo "Creating .gitignore file for Obsidian..."
        echo ".obsidian/workspace" > .gitignore
        echo ".obsidian/cache" >> .gitignore
        echo ".trash/" >> .gitignore
        git add .gitignore
        git commit -m "Add .gitignore for Obsidian"
    elif ! grep -q ".obsidian/workspace" .gitignore; then
        echo "Updating .gitignore for Obsidian..."
        echo ".obsidian/workspace" >> .gitignore
        echo ".obsidian/cache" >> .gitignore
        echo ".trash/" >> .gitignore
        git add .gitignore
        git commit -m "Update .gitignore for Obsidian"
    fi
}

# Main script
check_ssh_key
check_git_repository
setup_gitignore

# Set up remote repository if not already set
if ! git remote get-url origin &> /dev/null; then
    read -p "Enter GitHub repository name: " repo_name
    git remote add origin "git@github.com:$GITHUB_USERNAME/$repo_name.git"
    git branch -M main
    git push -u origin main
fi

echo "Git repository is set up and ready for use with Obsidian."