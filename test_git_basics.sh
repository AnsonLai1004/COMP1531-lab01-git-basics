#!/bin/bash

commits=`git rev-list HEAD --count`

if [ "$commits" -eq 1 ]
then
    echo 'You did not make a commit :(.'
    exit 1
else
    echo "Tests passed!"
fi
