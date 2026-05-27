# Recipe for running local coding agent with llama.cpp + pi.dev

## Running the local LLM

1) Clone this repo with `git clone --recurse-submodules <url>`
2) Copy .envrc.example to .envrc and optionally edit the options
3) Build the image with `source .envrc && ./podman-build-image.sh`
4) Run the llama.cpp server with `source .envrc && ./podman-run-server.sh`
5) Test the model by going to https://localhost:8080/

## Running pi coding agent

1) Install https://pi.dev coding agent (NOTE: pi has no sandbox, better to run from container, see https://github.com/cjermain/pi-less-yolo)
2) Create `~/.pi/agent/models.json` with contents (NOTE: use the same model id you used in .envrc):
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
