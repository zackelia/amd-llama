FROM rocm/dev-ubuntu-22.04:5.7-complete AS builder

ENV LLAMA_CPP_PYTHON_RELEASE 0.2.50

# From /opt/rocm/lib/rocblas/library/
ENV AMDGPU_TARGETS gfx803;gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a:xnack+;gfx90a:xnack-;gfx940;gfx941;gfx942;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102
ENV CMAKE_C_COMPILER /opt/rocm/llvm/bin/clang
ENV CMAKE_CXX_COMPILER /opt/rocm/llvm/bin/clang++
# Ninja automatically gets parallelized builds with scikit-build
ENV CMAKE_GENERATOR="Ninja"

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y \
    cmake python3-venv

RUN python3 -m venv venv && \
    CMAKE_GENERATOR="${CMAKE_GENERATOR}" \
    CMAKE_ARGS="-DAMDGPU_TARGETS=${AMDGPU_TARGETS} \
                -DLLAMA_HIPBLAS=ON \
                -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} \
                -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}" \
    /venv/bin/pip install "llama-cpp-python[server]==${LLAMA_CPP_PYTHON_RELEASE}"

FROM rocm/dev-ubuntu-22.04:5.7

COPY --from=builder /venv /venv

# Maybe this isn't great with layering? But using 5.7 and copying the libraries
# versus 5.7-complete is a savings of ~9GB.
COPY --from=builder /opt/rocm-5.7.0/lib/libhipblas.so.1 /opt/rocm/lib
COPY --from=builder /opt/rocm-5.7.0/lib/librocblas.so.3 /opt/rocm/lib
COPY --from=builder /opt/rocm-5.7.0/lib/librocsolver.so.0 /opt/rocm/lib
COPY --from=builder /opt/rocm-5.7.0/lib/librocsparse.so.0 /opt/rocm/lib
COPY --from=builder /opt/rocm/lib/rocblas/library /opt/rocm/lib/rocblas/library

EXPOSE 8000

ENTRYPOINT ["/venv/bin/python", "-m", "llama_cpp.server", "--host", "0.0.0.0", "--port", "8000"]
