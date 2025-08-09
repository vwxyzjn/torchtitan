#!/usr/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

set -ex

# use envs as local overrides for convenience
# e.g.
# LOG_RANK=0,1 NGPU=4 ./run_train.sh
export NGPU=${NGPU:-"8"}
export LOG_RANK=${LOG_RANK:-0}
export CONFIG_FILE=${CONFIG_FILE:-"./torchtitan/models/llama3/train_configs/debug_model.toml"}

overrides=""
if [ $# -ne 0 ]; then
    overrides="$*"
fi

export TORCHFT_LIGHTHOUSE=${TORCHFT_LIGHTHOUSE:-"http://localhost:29510"}
export PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True"

if [ -z "$VC_WORKER_NUM" ] || [ "$VC_WORKER_NUM" = "1" ]; then # single node
    torchrun --nproc_per_node="${NGPU}" --rdzv_backend c10d --rdzv_endpoint="localhost:0" \
    --local-ranks-filter ${LOG_RANK} --role rank --tee 3 \
    -m torchtitan.train --job.config_file ${CONFIG_FILE} $overrides
else # multinode
  RDZV_ID=${RDZV_ID:-1}
  RDZV_HOST="${VC_WORKER_HOSTS%%,*}"
  torchrun --nnodes "${VC_WORKER_NUM}" --nproc_per_node="${NGPU}" --rdzv_backend c10d \
    --rdzv_endpoint "${RDZV_HOST}:29500" --rdzv_conf read_timeout=3600 --rdzv_id "${RDZV_ID}" \
    --local-ranks-filter ${LOG_RANK} --role rank --tee 3 \
    -m torchtitan.train --job.config_file ${CONFIG_FILE} $overrides
fi
