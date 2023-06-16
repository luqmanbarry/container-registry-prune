# Registry Cleanup

This script inspects a specific container image, prune all image tags associated to it, and skip the `N` most recent image tags.

Some container registries have this capability builtin. For example, images from the OpenShift image registry that are no longer required by the system due to age, status, or exceed limits are [automatically pruned](https://docs.openshift.com/container-platform/4.11/applications/pruning-objects.html#pruning-images_pruning-objects). Cluster administrators can configure the Pruning Custom Resource (`imagepruners.imageregistry.operator.openshift.io`), or suspend it. 

> Search for this feature in the docs of said product before trying this solution. In a Kubernetes environment, you could place this script in a `CronJob` so that it runs periodically.

## Pre-requisites

- Container registry
- Container registry user account with write access
- jq, skopeo

## Invocation Example

```bash
# Note: Tag is not specified
IMAGE_REGISTRY_URL="registry-host.example.com/app-org/app-image"
REGISTRY_USERNAME="my-username"
REGISTRY_PASSWORD="my-password"
TAG_KEEP_COUNT=10

sh registry-cleanup.sh ${IMAGE_REGISTRY_URL} \
    ${REGISTRY_USERNAME} \
    ${REGISTRY_PASSWORD} \
    ${TAG_KEEP_COUNT}
```
