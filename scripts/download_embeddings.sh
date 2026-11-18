#!/usr/bin/env bash
# Download ChromBERT region embeddings from Hugging Face and extract zarr.
#
# Dataset: https://huggingface.co/datasets/llzzhh0512/ChromBERT-REGAIN
#
# Usage (from repo root):
#   bash scripts/download_embeddings.sh              # both hg38 + mm10
#   GENOME=hg38 bash scripts/download_embeddings.sh  # human only
#   GENOME=mm10 bash scripts/download_embeddings.sh  # mouse only
#   DEST=/path/to/dir bash scripts/download_embeddings.sh
#
# Requires: huggingface_hub CLI (pip install -U "huggingface_hub[cli]") and tar.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${DEST:-${ROOT}/embeddings}"
REPO="llzzhh0512/ChromBERT-REGAIN"
GENOME="${GENOME:-all}"   # hg38 | mm10 | all

mkdir -p "${DEST}"
cd "${DEST}"

if ! command -v huggingface-cli >/dev/null 2>&1; then
  echo "Installing huggingface_hub CLI ..."
  python -m pip install -U "huggingface_hub[cli]"
fi

extract_one() {
  local FILE="$1"
  local ZARR_NAME="$2"
  local TAR_PATH OUT_ZARR tmpdir top

  echo "Downloading ${FILE} from Hugging Face (${REPO}) → ${DEST}"
  huggingface-cli download "${REPO}" "${FILE}" \
    --repo-type dataset \
    --local-dir "${DEST}"

  TAR_PATH="${DEST}/${FILE}"
  if [[ ! -f "${TAR_PATH}" ]]; then
    # hub may nest under snapshots; search one level
    TAR_PATH="$(find "${DEST}" -name "${FILE}" -type f | head -n 1)"
  fi
  if [[ -z "${TAR_PATH}" || ! -f "${TAR_PATH}" ]]; then
    echo "ERROR: could not find ${FILE} under ${DEST}" >&2
    exit 1
  fi

  OUT_ZARR="${DEST}/${ZARR_NAME}"
  mkdir -p "${OUT_ZARR}"
  echo "Extracting ${TAR_PATH} → ${OUT_ZARR}"
  # archive may be either a bare zarr tree or a top-level folder; normalize
  tmpdir="$(mktemp -d)"
  tar -xf "${TAR_PATH}" -C "${tmpdir}"
  if [[ -d "${tmpdir}/full" ]]; then
    # tar contained zarr root contents
    shopt -s dotglob
    mv "${tmpdir}"/* "${OUT_ZARR}/"
    shopt -u dotglob
  elif [[ -d "${tmpdir}/${ZARR_NAME}/full" ]]; then
    mv "${tmpdir}/${ZARR_NAME}"/* "${OUT_ZARR}/"
  else
    # single top-level directory
    top="$(find "${tmpdir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    if [[ -n "${top}" && -d "${top}/full" ]]; then
      mv "${top}"/* "${OUT_ZARR}/"
    else
      echo "ERROR: unexpected archive layout under ${tmpdir}" >&2
      find "${tmpdir}" | head -n 50 >&2
      exit 1
    fi
  fi
  rm -rf "${tmpdir}"

  echo "  → ${OUT_ZARR}/full"
}

case "${GENOME}" in
  hg38|human)
    extract_one "atac_embs_dim.tar" "atac_embs_dim.zarr"
    ;;
  mm10|mouse)
    extract_one "atac_embs_dim_mm10.tar" "atac_embs_dim_mm10.zarr"
    ;;
  all|both)
    extract_one "atac_embs_dim.tar" "atac_embs_dim.zarr"
    extract_one "atac_embs_dim_mm10.tar" "atac_embs_dim_mm10.zarr"
    ;;
  *)
    echo "ERROR: GENOME must be hg38, mm10, or all (got: ${GENOME})" >&2
    exit 1
    ;;
esac

echo "Done. Point --emb_dir to the matching zarr, e.g.:"
echo "  ${DEST}/atac_embs_dim.zarr        # hg38"
echo "  ${DEST}/atac_embs_dim_mm10.zarr   # mm10"
echo "Expect array: <zarr>/full"
