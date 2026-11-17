#!/usr/bin/env bash
# ChromBERT-REGAIN imputation example (full-scale paths).
# For the tiny offline demo, use: bash examples/demo/run_demo.sh
#
# Override with env vars:
#   INPUT  OUTPUT  EMB_DIR  EMB_DIM  TOPICS  ...

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="${INPUT:-${ROOT}/data/peaks_indexed.h5ad}"
OUTPUT="${OUTPUT:-${ROOT}/output/peaks_imputed_ALS.h5ad}"
EMB_DIR="${EMB_DIR:-${ROOT}/embeddings/atac_embs_dim.zarr}"
EMB_DIM="${EMB_DIM:-768}"
TOPICS="${TOPICS:-128}"
LAMBDA_A="${LAMBDA_A:-1}"
LAMBDA_B="${LAMBDA_B:-0.1}"
ALS_ITERS="${ALS_ITERS:-20}"
CG_ITERS="${CG_ITERS:-500}"
CG_TOL="${CG_TOL:-1e-5}"
SEED="${SEED:-42}"

mkdir -p "$(dirname "${OUTPUT}")"

if [[ ! -d "${EMB_DIR}" ]]; then
  echo "ERROR: emb_dir not found: ${EMB_DIR}" >&2
  echo "Download with: bash scripts/download_embeddings.sh" >&2
  echo "Or run the tiny demo: bash examples/demo/run_demo.sh" >&2
  exit 1
fi

if [[ ! -f "${INPUT}" ]]; then
  echo "ERROR: input not found: ${INPUT}" >&2
  echo "Prepare indices with scripts/prepare_peak_indices.py" >&2
  exit 1
fi

python -u "${ROOT}/regain/impute_als.py" \
  --input "${INPUT}" \
  --output "${OUTPUT}" \
  --emb_dir "${EMB_DIR}" \
  --emb_dim "${EMB_DIM}" \
  --topics "${TOPICS}" \
  --lambdaA "${LAMBDA_A}" \
  --lambdaB "${LAMBDA_B}" \
  --als_iters "${ALS_ITERS}" \
  --cg_iters "${CG_ITERS}" \
  --cg_tol "${CG_TOL}" \
  --binary \
  --seed "${SEED}"

echo "Wrote ${OUTPUT}"
