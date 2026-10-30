#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/llama-models.ini" ]; then
  echo "Error: $SCRIPT_DIR/llama-models.ini is missing." >&2
  exit 1
fi

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

if [ "$LLAMA_CPP_RUN_SHELL" == "1" ] || [ "$LLAMA_CPP_RUN_SHELL" == "true" ]; then
    echo "Starting bash shell instead of running llama-server."
    EXTRA_PODMAN_ARGS+=(--interactive --tty --entrypoint /bin/bash)
    LLAMA_CPP_ARGS=()
fi

# .envrc exports arguments as a whitespace-separated string for this script.
read -r -a SERVER_ARGS <<< "${LLAMA_CPP_ARGS:-}"
echo "Using image: $LLAMA_CPP_IMAGE"
echo "Arguments:" "${SERVER_ARGS[@]}" "$@"

podman run --rm --device nvidia.com/gpu=all \
       -v llama-cpp-cache:/root/.cache \
       -v "$SCRIPT_DIR/llama-models.ini:/app/llama-models.ini:ro,Z" \
       --network=host \
       "${EXTRA_PODMAN_ARGS[@]}" \
       "${LLAMA_CPP_IMAGE}" \
       "${SERVER_ARGS[@]}" \
       "${@}"
