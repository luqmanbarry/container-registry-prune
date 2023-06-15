# Registry Cleanup

This script inspects a specific container image, prune all image tags associated to it, and skip the `N` most recent image tags.

## Invocation Example

```bash
# Note: Tag is not specified
IMAGE_REGISTRY_URL="registry-host.example.com/app-org/ose-tools-rhel8"
REGISTRY_USERNAME="my-username"
REGISTRY_PASSWORD="my-password"
TAG_KEEP_COUNT=10

sh registry-cleanup.sh ${IMAGE_REGISTRY_URL} \
    ${REGISTRY_USERNAME} \
    ${REGISTRY_PASSWORD} \
    ${TAG_KEEP_COUNT}
```