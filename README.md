Rootless Ubuntu Docker in Docker image


## Build Docker in Docker rootless

```shell
export ROOTLESS_IMAGE_VERSION=1.0.0
export IMAGE_NAME="ubuntu-22-dind-rootless"

DOCKER_REGISTRY_URL="%YOUR_REGISTRY_URL%"

docker buildx create --use --name insecure-builder --buildkitd-flags '--allow-insecure-entitlement security.insecure'
docker buildx use insecure-builder
docker builder prune --force

# image remains locally (not pushed to docker registry)
#docker buildx build --allow security.insecure --load -t "$IMAGE_NAME:$ROOTLESS_IMAGE_VERSION" .

# build and push to registry
docker buildx build --allow security.insecure --push -t "$DOCKER_REGISTRY_URL/$IMAGE_NAME:$ROOTLESS_IMAGE_VERSION" -t "$DOCKER_REGISTRY_URL/$IMAGE_NAME:latest" .

docker buildx rm insecure-builder
```

## Run container
```shell
docker run --privileged --rm -it ubuntu-22-dind-rootless:1.0.0
```
