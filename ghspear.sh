#!/bin/bash
########################################################################################
# Script Name:   ghspear
# Description:   Interactively view or download files from GitHub repositories. Users
#                can select repositories, branches, and files using fuzzy finding (fzf).
#
# Usage:         ghspear [-w] [-o <owner>] [-h]
#
# Options:
#   -w <web>         Open the selected file in a web browser instead of downloading it.
#   -o <owner>       Specify the owner, owner/repo, or owner/repo/branch directly.
#   -h <help>        Display this help message and exit.
#
# Examples:
#   ghspear
#   ghspear -w -o <username>
#   ghspear -o <username>/<repo>
#   ghspear -o <username>/<repo>/<branch>
#
# Author:        pwhybra
# Repo:          https://github.com/pwhybra/ghspear
#
# Dependencies:  - gh: GitHub CLI.
#                - jq: For JSON parsing.
#                - fzf: For fuzzy finding.
#
# Notes:         - Ensure you are authenticated with GitHub CLI (`gh auth login`).
#                - Feel free to modify, though keep reference to original author/repo.
#                - If you find it useful let me know with a repo star :)
########################################################################################

# Default settings
OPEN_IN_BROWSER=false
OWNER=""
REPO=""
BRANCH=""
LIMIT=2000

# Process arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -w)
            OPEN_IN_BROWSER=true
            shift  # Remove the flag from arguments
            ;;
        -o)
            if [[ -n "$2" ]]; then
                OWNER="$2"
                shift 2  # Remove both the flag and the owner argument
            else
                echo "Error: -o requires an argument."
                exit 1
            fi
            ;;
        -h)
            echo "Usage: ghspear [-w view on web instead of download]\
             [-o <owner/repo/branch> search repos or owner/repo directly]"
            exit 1
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Determine repository and branch if provided
echo ""
echo "View or Download a file from a GitHub repo"
echo ""

if [[ "$OWNER" == */* ]]; then
    # Split OWNER into REPO and optionally BRANCH
    REPO=$(echo "$OWNER" | cut -d'/' -f1-2)
    BRANCH=$(echo "$OWNER" | cut -d'/' -f3)
    echo "Using specified repository: $REPO"
    if [[ -n "$BRANCH" ]]; then
        echo "Using specified branch: $BRANCH"
    fi
else
    # Fetch and select from the owner's repositories
    echo "Fetching repository list..."
    if [[ -z "$OWNER" ]]; then
        # Default to listing personal repositories
        REPO=$(gh repo list \
        --limit $LIMIT \
        --json nameWithOwner \
        -q '.[].nameWithOwner' | \
        fzf --height 60% --border --padding=1% \
        --reverse --prompt="Select a repository: ")
    else
        # List repositories for the specified owner
        REPO=$(gh repo list "$OWNER" \
        --limit $LIMIT \
        --json nameWithOwner \
        -q '.[].nameWithOwner' | \
        fzf --height 60% --border --padding=1% --reverse \
        --prompt="Select a repository: ")
    fi

    if [[ -z "$REPO" ]]; then
        echo "No repository selected."
        exit 1
    fi
    echo "Selected repository: $REPO"
fi

# If no branch was provided, list branches for the selected repo and pick one
if [[ -z "$BRANCH" ]]; then
    echo "Fetching branches for repository $REPO..."
    BRANCHES_JSON=$(gh api -H \
    "Accept: application/vnd.github.v3+json" "/repos/$REPO/branches?per_page=100")

    BRANCH=$(echo "$BRANCHES_JSON" | jq -r '.[].name' | \
    fzf --height 80% --border --padding=1% --reverse --prompt="Select a branch: ")

    if [[ -z "$BRANCH" ]]; then
        echo "No branch selected."
        exit 1
    fi
    echo "Selected branch: $BRANCH"
fi

# List files in the branch and pick one or more
echo "Fetching file tree for branch $BRANCH in repository $REPO..."
FILES_JSON=$(gh api -H "Accept: application/vnd.github.v3+json" \
"/repos/$REPO/git/trees/$BRANCH?recursive=1")

# Use fzf with --multi to allow selecting multiple files
FILES=$(echo "$FILES_JSON" | jq -r '.tree[] | select(.type == "blob") | .path' | \
fzf --multi --height 80% --border --padding=1% --reverse --prompt="Select file(s): ")

if [[ -z "$FILES" ]]; then
    echo "No files selected."
    exit 1
fi

# Loop through each selected file and download or open it
echo "Selected file(s):"
echo "$FILES"

IFS=$'\n' # Split FILES on newlines
for FILE in $FILES; do
    if [[ "$OPEN_IN_BROWSER" == true ]]; then
        # Open file in browser
        echo "Opening $FILE in the web browser..."
        FILE_URL="https://github.com/$REPO/blob/$BRANCH/$FILE"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$FILE_URL" # macos
        else
            xdg-open "$FILE_URL" # linux
        fi
    else
        # Download the file content
        echo "Downloading $FILE from $REPO (branch: $BRANCH)..."
        gh api -H "Accept: application/vnd.github.v3.raw" \
        "/repos/$REPO/contents/$FILE?ref=$BRANCH" > "$(basename "$FILE")"
        echo "File saved as $(basename "$FILE")"
    fi
done