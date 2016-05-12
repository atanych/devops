#!/bin/bash

branch=staging

echo ""
cd ~/rails-apps/admin

echo "$(tput setaf 2)Getting last changes from bitbucket$(tput sgr 0)"

git fetch
git merge origin/$branch

cd src
npm install

bower install

gulp constants
gulp $branch


echo "$(tput setaf 2) ---------------------- Done!!! ---------------------$(tput sgr 0)"