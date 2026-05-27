#!/bin/bash

if [ -z "$LLAMA_CPP_IMAGE" ]; then
  echo "Error: LLAMA_CPP_IMAGE is not defined." >&2
  exit 1
fi

if ! podman volume inspect llama-cpp-cache &>/dev/null; then
    echo "Creating podman volume storing llama.cpp model weights: llama-cpp-cache"
    podman volume create llama-cpp-cache > /dev/null
fi

EXTRA_PODMAN_ARGS=()

if [ -n "$HF_TOKEN" ]; then
    echo "Passing HF_TOKEN environment variable to container."
    EXTRA_PODMAN_ARGS+=(--env HF_TOKEN="${HF_TOKEN}")
fi

echo "Using image: "${LLAMA_CPP_IMAGE}""
echo "Arguments:" "${LLAMA_CPP_ARGS[@]}"

podman run --rm --device nvidia.com/gpu=all \
       -v llama-cpp-cache:/root/.cache \
       --network=host \
       "${EXTRA_PODMAN_ARGS[@]}" \
       "${LLAMA_CPP_IMAGE}" \
       ${LLAMA_CPP_ARGS[@]}
