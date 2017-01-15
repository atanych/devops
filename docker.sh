docker images # images list
docker run <image> # run container
docker ps # list of running containers
docker ps -a # list of all containers
docker run -it busybox sh # run container in interative mode

docker rm <container_id> 
docker rm $(docker ps -a -q -f status=exited) # remove all unused containers
