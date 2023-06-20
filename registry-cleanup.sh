#!/bin/bash

# Script Arguments
# IMAGE_REGISTRY_URL: The image url in the resgistry without tags. For example: registry.redhat.io/openshift4/ose-tools-rhel8
# REGISTTRY_USERNAME: The username to use
# REGISTRY_PASSWORD: The password to use
# TAG_KEEP_COUNT: Number of tags to keep. The script expects an integer. The default is 2.
IMAGE_REGISTRY_URL=$1
REGISTTRY_USERNAME=$2
REGISTRY_PASSWORD=$3
TAG_KEEP_COUNT=$4


TEMP_TAGS="/tmp/image-tags.txt"
IMAGE_TAGS=$(skopeo list-tags \
    "docker://${IMAGE_REGISTRY_URL}" \
    --tls-verify=false \
    --username "${REGISTTRY_USERNAME}" \
    --password "${REGISTRY_PASSWORD}" \
    --retry-times 10 \
    | jq -r .Tags | sed 1,1d | sed '$d' | sed 's/"//g;s/,//g')

TAG_COUNT=$(echo "$IMAGE_TAGS" | wc -l)
echo "Tag Count: $TAG_COUNT"

# Set default value is TAG_KEEP_COUNT is empty
if [ -z "$TAG_KEEP_COUNT" ];
then
   TAG_KEEP_COUNT=3
fi 

if [ $TAG_COUNT -gt $TAG_KEEP_COUNT ];
then
    rm -rf $TEMP_TAGS || true
    
    for TAG_NAME in $(echo "$IMAGE_TAGS")
    do
        TAG_DATE=$(skopeo inspect \
            "docker://${IMAGE_REGISTRY_URL}:${TAG_NAME}" \
            --tls-verify=false \
            --username "${REGISTTRY_USERNAME}" \
            --password "${REGISTRY_PASSWORD}" \
            --retry-times 10 \
            --override-os linux | jq -r .Created)

        echo "$TAG_DATE  $TAG_NAME" >> $TEMP_TAGS

        tail -n1 "$TEMP_TAGS"

    done

    echo "Skipped Tags: $(cat $TEMP_TAGS | sort -rn -k1 | head -n $TAG_KEEP_COUNT)"
    DELETE_COUNT=$((TAG_KEEP_COUNT+1))
    DELETE_CANDIDATES=$(cat $TEMP_TAGS | sort -rn -k1 | tail -n +$DELETE_COUNT | awk '{print $2}')
    
    for DEL_TAG_NAME in $(echo "$IMAGE_TAGS") 
    do
        echo "Deleting Image with tag: $DEL_TAG_NAME"
        skopeo delete \
            "docker://${IMAGE_REGISTRY_URL}:$DEL_TAG_NAME" \
            --tls-verify=false \
            --username "${REGISTTRY_USERNAME}" \
            --password "${REGISTRY_PASSWORD}" \
            --retry-times 10 \
            --debug
    done

else 
    echo "No image cleanup. Minimum tags required is $TAG_KEEP_COUNT"
fi


rm -rf $TEMP_TAGS || true
