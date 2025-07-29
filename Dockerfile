# Default use the NVIDIA official image with PyTorch 2.3.0
# https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/index.html
# BASE_IMAGE=nvcr.io/nvidia/pytorch:24.02-py3
# https://github.com/orgs/pytorch/packages/container/pytorch-nightly/versions
ARG BASE_IMAGE=ghcr.io/pytorch/pytorch-nightly:2.9.0.dev20250728-cuda12.9-cudnn9-devel
FROM ${BASE_IMAGE}

RUN apt-get -y update && \
    apt-get -y install git build-essential && \
    git clone --depth 1 -b merge-rick-branch https://github.com/vwxyzjn/torchtitan && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR torchtitan

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -e .

RUN python scripts/download_tokenizer.py --repo_id deepseek-ai/DeepSeek-V3 && \
    rm -rf /root/.cache/huggingface



