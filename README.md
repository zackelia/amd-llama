# amd-llama
Docker image with AMD support for llama_cpp_python+chatbot-ui

## Prerequisites

Install amdgpu driver with ROCm 6.0.2 support. Download at https://www.amd.com/en/support/linux-drivers

Instructions adapted from https://amdgpu-install.readthedocs.io/en/latest/install-installing.html

```
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb
amdgpu-install -y --accept-eula --usecase=rocm
sudo usermod -a -G render $LOGNAME
sudo usermod -a -G video $LOGNAME
```

Reboot for changes to take effect.

## Usage

`amd-llama` is currently built for gfx803, gfx900, gfx906:xnack-, gfx908:xnack-, gfx90a:xnack+, gfx90a:xnack-, gfx940, gfx941, gfx942, gfx1010, gfx1012, gfx1030, gfx1100, gfx1101, gfx1102. You can check what processor your GPU is by either visiting LLVM's documentation (https://llvm.org/docs/AMDGPUUsage.html#id16) or by running the following command:

```
rocminfo | grep gfx
```

If your processor is not built by `amd-llama`, you will need to provide the `HSA_OVERRIDE_GFX_VERSION` environment variable with the closet version. For example, an RX 67XX XT has processor gfx1031 so it should be using gfx1030. To use gfx1030, set `HSA_OVERRIDE_GFX_VERSION=10.3.0` in docker-compose.yml.

In order to take advantage of the GPU, you must provide the `--n_gpu_layers` argument. The value it takes depends on available VRAM. For example, a model's output will show this:
```
amd-llama  | llm_load_tensors: offloaded 35/35 layers to GPU
amd-llama  | llm_load_tensors: VRAM used: 4807.05 MiB
```

To use your GPU fully, `--n_gpu_layers` should be greater than or equal to the necessary layers for the model; in this case, >= 35. If you use too many layers and exceed your VRAM, you will crash the server.

To run the server and web UI, run the following:

```
docker compose up -d
```

Download compatible models (*.gguf) to the `models` directory.
