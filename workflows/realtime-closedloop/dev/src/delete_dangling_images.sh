
docker images -qf "dangling=true"

docker rmi $(docker images -qf "dangling=true")
docker images
