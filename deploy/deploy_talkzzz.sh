#!/bin/bash

RAILS_ENV=staging

echo ""
cd ~/rails-apps/talkzzz

echo "$(tput setaf 2)Getting last changes from bitbucket$(tput sgr 0)"

#git checkout deployment
git fetch
git merge origin/staging

echo "$(tput setaf 2) Switching gemset to ruby-2.2.3@talkzzz$(tput sgr 0)"
rvm gemset use ruby-2.2.3@talkzzz

#if [ -f tmp/pids/server.pid ]; then
#    echo "$(tput setaf 2) Running server found. Stoping it.$(tput sgr 0)"
#    cat tmp/pids/server.pid | xargs kill
#fi

echo "$(tput setaf 2) Cleaning cache$(tput sgr 0)"
rm -Rf ~/rails-apps/talkzzz/tmp/cache

while [ ! $# -eq 0 ]
do
    case "$1" in
        --migrate | -m)
            MIGRATE=TRUE
            ;;
        --precompile | -p)
            PRECOMPILE=TRUE
            ;;
        --bundle | -b)
            BUNDLE=TRUE
            ;;
    esac
    shift
done

#if [ "$BUNDLE" = TRUE ] ; then
  echo "$(tput setaf 2) Bundle install!$(tput sgr 0)"
  bundle install
#fi

#if [ "$MIGRATE" = TRUE ] ; then
  echo "$(tput setaf 2) Running migrations$(tput sgr 0)"
   RAILS_ENV=$RAILS_ENV rake db:migrate
#fi

#if [ "$PRECOMPILE" = TRUE ] ; then
  echo "$(tput setaf 2) Precompiling assets$(tput sgr 0)"
  RAILS_ENV=$RAILS_ENV rake assets:precompile
#fi

#echo "$(tput setaf 2) Restarting sidekiq$(tput sgr 0)"
#ps -ef | grep sidekiq | awk '{print $2}' | xargs kill
#sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml -e staging

#echo "$(tput setaf 2) Restarting nginx server$(tput sgr 0)"
#sudo service nginx restart
#sudo kill `cat /var/run/nginx.pid`
#sudo /opt/nginx/sbin/nginx

echo "$(tput setaf 2) Restarting puma server$(tput sgr 0)"
#sudo kill `cat ./tmp/pids/puma.pid`
#puma -b unix://./tmp/sockets/puma.sock -e staging -t 1024:1024 -w 2 --preload -d --pidfile ./tmp/pids/puma.pid
talkzzz restart

#echo "$(tput setaf 2) Updating scheduled jobs$(tput sgr 0)"
whenever --update-crontab --set environment=$RAILS_ENV

echo "$(tput setaf 2) ---------------------- Done!!! ---------------------$(tput sgr 0)"