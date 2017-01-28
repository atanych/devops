docker images # images list
docker run <image> # run container
docker ps # list of running containers
docker ps -a # list of all containers

docker run -it busybox sh # run container in interative mode
docker run -p 8888:80 prakhar1989/static-site # run and map ports
docker run -d -P --name st static # all ports, daemon, st - container name, static - image name
docker run -v /var/www:/usr/share/ -d -p 8888:80 --name st static # mount /var/www -> /usr/share
# trick http://stackoverflow.com/questions/28212380/why-docker-container-exits-immediately 
docker run -d ubuntu /sbin/init
docker run -dit ubuntu

docker run busybox echo "hello from busybox" # run 
docker stop <container_name>
docker start <container_name>

docker rm <container_id> 
docker rm $(docker ps -a -q -f status=exited) # remove all unused containers

docker port <container> # opened ports

# Dockerfile
docker build -t atanych . # create image from dockerfile

docker exec -it 1da24e7e5f6f bash # enter to container 

docker commit -m 'commit message' 7c8d922dc0ea atanych/python # commit current container 7c8d922dc0ea to image atanych/python
docker push atanych/python
docker login

docker history atanych/python - image history

# init self image
docker pull phusion/baseimage
docker run -i -t phusion/baseimage:latest /sbin/my_init -- bash -l
docker commit <container_hash> atanych/<repo>

# backup volumes
docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata
docker run -v /dbdata --name dbstore2 ubuntu /bin/bash
docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"

# postgres 
docker run -d -p 5432:5432 -e POSTGRES_USER='atanych' -e POSTGRES_DB='psy_docker' \
-e POSTGRES_PASSWORD='asdasd' -v /run/postgresql:/run/postgresql -v pg_volume:/var/lib/postgresql/data --name pg postgres
