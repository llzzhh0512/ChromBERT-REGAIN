#!/usr/bin/env bash
# Toy smoke-test: tiny demo peaks + mini embedding (no full HF download).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEMO="$(cd "$(dirname "$0")" && pwd)"

INPUT="${INPUT:-${DEMO}/demo_peaks.h5ad}"
EMB_DIR="${EMB_DIR:-${DEMO}/demo_emb.zarr}"
OUTPUT="${OUTPUT:-${DEMO}/output/demo_imputed.h5ad}"

mkdir -p "$(dirname "${OUTPUT}")"

python -u "${ROOT}/regain/impute_als.py" \
  --input "${INPUT}" \
  --output "${OUTPUT}" \
  --emb_dir "${EMB_DIR}" \
  --emb_dim 768 \
  --topics 32 \
  --lambdaA 1 \
  --lambdaB 0.1 \
  --als_iters 5 \
  --cg_iters 100 \
  --cg_tol 1e-5 \
  --binary \
  --seed 42

echo "Wrote ${OUTPUT}"
