# Recipe for running local coding agent with llama.cpp + pi.dev

## Running the local LLM

1) Clone this repo with `git clone --recurse-submodules <url>`
2) Copy .envrc.example to .envrc and optionally edit the options
3) Build the image with `source .envrc && ./podman-build-image.sh`
4) Run the llama.cpp server with `source .envrc && ./podman-run-server.sh`
5) Test the model by going to https://localhost:8080/

## Running pi coding agent

> [!CAUTION]
> Pi has [no sandbox](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/#toc_13) and allows the LLM to run **any command, including destructive ones,** on your system. For minimum security, it is better to run it from a container, see https://github.com/cjermain/pi-less-yolo .

> [!NOTE]
> In the `models.json` file, use the same model id you used in your `.envrc` file.

1) Install https://pi.dev coding agent (NOTE: as mentioned above, better to run from a container)
2) Create `~/.pi/agent/models.json` with contents:
    ```json
    {
    "providers": {
        "localhost": {
        "baseUrl": "http://localhost:8080/v1",
        "api": "openai-completions",
        "apiKey": "none",
        "models": [
            {
            "id": "unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M",
            "input": ["text", "image"]
            }
        ]
        }
    }
    }
    ```
3) Now run pi.
