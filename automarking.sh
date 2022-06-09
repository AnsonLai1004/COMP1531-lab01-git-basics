#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: $0 CI_PROJECT_NAME"
    exit 1
fi

CI_PROJECT_NAME=$1

for branch in $(git branch -r | grep -v '\-> \| old' | cut -c3-); do
    # Fixme: for 22T3, also add marking/solution to hidden list.
    if [ "$branch" != "origin/master" ]; then
        git branch --track "${branch#origin/}" "$branch"
    fi
done | cat -n

mark=0

echo -e "\n=== Viewing Git Branches ==="
git branch

echo -e "\n=== Viewing Git Log ==="
git log --color --graph --pretty=tformat:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cD) %C(bold blue)%an%Creset' --abbrev-commit

echo -e "\n==========================================="
echo "Basic Component (Add, Commit, Push)"

echo
files="$(find . -type f ! \( -name '*.md' -o -name '*.sh' -o -name '.git*' \))"
numFiles="$(echo $files | grep -vc '^\s*$')"

echo Files:
echo "$files"
echo Number of Files: 
echo "$numFiles"

echo
if [ "$numFiles" -eq 0 ]
then
    echo 'You did not create any files :(.'
else
    echo "Tests passed!"
    mark=$(echo "scale=2; $mark + 0.5" | bc | awk '{printf "%.2f", $0}')
fi

echo -e "\n==========================================="
echo "Advance Component (Branch, Merge)"

branches="$(git branch | egrep -v "marking|solution" | wc -l)"
success=0
if [ "$branches" -eq 1 ]
then
    echo 'You did not create a branch'
    success=1
fi

merges="$(git log --merges --format="%aE" | wc -l)"
if [ "$merges" -eq 0 ]
then
    echo 'You did not do a merge? :( (at least not on this branch)'
    success=1
fi

if [ "$success" -eq 0 ]
then
    echo "Tests passed!"
    mark=$(echo "scale=2; $mark + 0.5" | bc | awk '{printf "%.2f", $0}')
fi

echo -e "\n==========================================="

echo "$CI_PROJECT_NAME|$mark| " | tee mark.txt
