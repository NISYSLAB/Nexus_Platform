
container_name=ubuntu21
docker rm -f "${container_name}"

docker run -d \
    --name "${container_name}" \
    -t ubuntu:21.04

docker exec -it "${container_name}" /bin/bash