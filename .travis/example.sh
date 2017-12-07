#!/bin/bash

git config --global user.name "mbed-bot"
git config --global user.email "mbed-bot@arm.com"

git fetch https://github.com/$1
git checkout FETCH_HEAD -b example
git merge master --no-edit
git push https://$GH_TOKEN@github.com/$1 example:master
git checkout master
git branch -D example
