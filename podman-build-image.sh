show_help() {
    echo "Usage: $0 --cuda CUDA_VERSION --ubuntu UBUNTU_VERSION --gcc GCC_VERSION [targets...]"
    echo ""
    echo "Arguments:"
    echo "  --cuda     CUDA version (e.g. 12.4.1), required (defaults to \$CUDA_VERSION env var if set)"
    echo "  --ubuntu   Ubuntu version (e.g. 22.04), required (defaults to \$UBUNTU_VERSION env var if set)"
    echo "  --gcc      GCC version (e.g. 12), required (defaults to \$GCC_VERSION env var if set)"
    echo ""
    echo "  targets    One or more of: full server light (defaults to server only)"
    echo ""
    echo "  --help     Show this help message and exit"
}

CUDA_VERSION="${CUDA_VERSION:-}"
UBUNTU_VERSION="${UBUNTU_VERSION:-}"
GCC_VERSION="${GCC_VERSION:-}"
TARGETS=()

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --cuda)
        CUDA_VERSION="$2"
        shift
        shift
        ;;
        --ubuntu)
        UBUNTU_VERSION="$2"
        shift
        shift
        ;;
        --gcc)
        GCC_VERSION="$2"
        shift
        shift
        ;;
        --help)
        show_help
        exit 0
        ;;
        *)
        TARGETS+=("$1")
        shift
        ;;
    esac
done

if [ -z "$CUDA_VERSION" ] || [ -z "$UBUNTU_VERSION" ] || [ -z "$GCC_VERSION" ]; then
    echo "Error: missing required arguments."
    show_help
    exit 1
fi

if [ -z "$TARGETS" ]; then
    TARGETS="server"
fi

echo "Build arguments:"
echo "  CUDA_VERSION   = $CUDA_VERSION"
echo "  UBUNTU_VERSION = $UBUNTU_VERSION"
echo "  GCC_VERSION    = $GCC_VERSION"
echo "  TARGETS        = $TARGETS"

cuda_version_major_minor=${CUDA_VERSION%.*}
cuda_tag=${cuda_version_major_minor//./}
git_tag="$(git describe --always --tags --dirty --long)"

for target in ${TARGETS}; do
    tag=${target}-cuda${cuda_tag}
    echo "Building $tag from git commit $git_tag"
    sleep 1
    podman build -f Containerfile ./llama.cpp/ \
           --ignorefile ./containerignore \
           --target $target \
           --build-arg=UBUNTU_VERSION=${UBUNTU_VERSION} \
           --build-arg=CUDA_VERSION=${CUDA_VERSION} \
           --build-arg=GCC_VERSION=${GCC_VERSION} \
           -t localhost/llama.cpp:${tag}-latest \
           -t localhost/llama.cpp:${tag}-${git_tag}
done
