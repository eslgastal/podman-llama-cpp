# Recipe for running local coding agent with llama.cpp + pi.dev

## Running the local LLM

1) Clone this repo with `git clone --recurse-submodules <url>`
2) Copy `.envrc.example` to `.envrc` and optionally edit the build variables and router/network options
3) LLM model selection, sampling, context, and tuning are in `llama-models.ini`. The defaults are tuned for an RTX 4070 GPU and i5-13600K CPU
3) *Optional:* for `load-mode = mlock` and `prio = 2` in `llama-models.ini` to work, run `sudo ./configure-linux-limits.sh`
4) Build the image with `source .envrc && ./podman-build-image.sh`
5) Run the llama.cpp router with `source .envrc && ./podman-run-server.sh` (the example binds to all interfaces, so use a firewall)
6) Test the model at `http://localhost:8080/`

## Running pi coding agent

> [!CAUTION]
> Pi has [no sandbox](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/#toc_13) and allows the LLM to run **any command, including destructive ones,** on your system. For minimum security, it is better to run it from a container, see https://github.com/cjermain/pi-less-yolo .

1) Install https://pi.dev coding agent (NOTE: as mentioned above, better to run from a container)
2) In Pi, run `/login llama.cpp` and enter a reachable router URL (`http://localhost:8080` if bound to all interfaces and Pi runs on the host) and an optional API key. Run `/model` to select the loaded model; `/llama` manages router models.
3) Done.
