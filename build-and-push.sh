#!/bin/env bash
#

REGISTRY_URL="docker.io/jamesregis"
OX_VERSION="7.10.6"

OX_DCS_CONTAINER="open-xchange-dcs"
OX_SPELLCHECK_CONTAINER="open-xchange-spellcheck"
OX_APPSUITE_CONTAINER="open-xchange-appsuite"

# remove local images
podman rmi localhost/deployment_spellcheck ${REGISTRY_URL}/${OX_SPELLCHECK_CONTAINER}:${OX_VERSION}
podman rmi localhost/deployment_dcs ${REGISTRY_URL}/${OX_DCS_CONTAINER}:${OX_VERSION}
podman rmi localhost/deployment_appsuite ${REGISTRY_URL}/${OX_APPSUITE_CONTAINER}:${OX_VERSION}

# build all images
podman-compose build

# tags images and push
podman tag localhost/deployment_spellcheck ${REGISTRY_URL}/${OX_SPELLCHECK_CONTAINER}:${OX_VERSION}
podman tag localhost/deployment_dcs ${REGISTRY_URL}/${OX_DCS_CONTAINER}:${OX_VERSION}
podman tag localhost/deployment_appsuite ${REGISTRY_URL}/${OX_APPSUITE_CONTAINER}:${OX_VERSION}

# podman tag localhost/open-xchange_spellcheck ${REGISTRY_URL}/${OX_SPELLCHECK_CONTAINER}:${OX_VERSION}
# podman tag localhost/open-xchange_dcs ${REGISTRY_URL}/${OX_DCS_CONTAINER}:${OX_VERSION}
# podman tag localhost/open-xchange_appsuite ${REGISTRY_URL}/${OX_APPSUITE_CONTAINER}:${OX_VERSION}


# push images to registry
echo "podman push ${REGISTRY_URL}/${OX_SPELLCHECK_CONTAINER}:${OX_VERSION}"
podman push ${REGISTRY_URL}/${OX_SPELLCHECK_CONTAINER}:${OX_VERSION}

echo "podman push ${REGISTRY_URL}/${OX_DCS_CONTAINER}:${OX_VERSION}"
podman push ${REGISTRY_URL}/${OX_DCS_CONTAINER}:${OX_VERSION}

echo "podman push ${REGISTRY_URL}/${OX_APPSUITE_CONTAINER}:${OX_VERSION}"
podman push ${REGISTRY_URL}/${OX_APPSUITE_CONTAINER}:${OX_VERSION}

