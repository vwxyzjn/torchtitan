uv sync
uv run python scripts/download_tokenizer.py --repo_id deepseek-ai/DeepSeek-V3

export NCCL_DEBUG=INFO
PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True" CONFIG_FILE="./torchtitan/models/deepseek_v3/train_configs/deepseek_v3_671b.toml" uv run --no-sync ./p_run_train.sh \
--training.steps=100000 \
--training.dataset=c4_test \
--training.local_batch_size=1 \
--parallelism.data_parallel_shard_degree=-1 \
--parallelism.tensor_parallel_degree=1 \
--parallelism.pipeline_parallel_degree=1 \
--parallelism.expert_parallel_degree=16 \
--metrics.log_freq=1 \