Rootless Ubuntu Docker in Docker image


## Build Docker in Docker rootless

```shell
export ROOTLESS_IMAGE_VERSION=1.0.0

IMAGE_FULL_NAME="ubuntu-22-dind-rootless:$ROOTLESS_IMAGE_VERSION"
DOCKER_REGISTRY_URL="%YOUR_REGISTRY_URL%"

docker buildx create --use --name insecure-builder --buildkitd-flags '--allow-insecure-entitlement security.insecure'
docker buildx use insecure-builder
docker builder prune --force

# image remains locally (not pushed to docker registry)
#docker buildx build --allow security.insecure --load -t "$IMAGE_FULL_NAME" .

# build and push to registry
docker buildx build --allow security.insecure --push -t "$DOCKER_REGISTRY_URL/$IMAGE_FULL_NAME" .

docker buildx rm insecure-builder
```

## Run container
```shell
docker run --privileged --rm -it ubuntu-22-dind-rootless:1.0.0
```
