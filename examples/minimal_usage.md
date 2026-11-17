# Minimal usage (full-scale data)

For a **no-download smoke-test**, prefer [`demo/README.md`](demo/README.md).

This page covers running on **your** peak matrix with the **genome-wide** ChromBERT embedding from Hugging Face.

## Prerequisites

1. `pip install -r requirements.txt`
2. `bedtools` on `PATH` (peak indexing only)
3. Embedding from https://huggingface.co/datasets/llzzhh0512/ChromBERT-REGAIN

```bash
bash scripts/download_embeddings.sh
# → embeddings/atac_embs_dim.zarr
```

## Steps

```bash
# 0) from repo root
cd ChromBERT-REGAIN
conda activate regain

# 1) Map peaks → ChromBERT bins (hg38)
python scripts/prepare_peak_indices.py \
  --input  data/raw_peaks.h5ad \
  --bins   annotations/hg38_6k_1kb_region.bed \
  --output data/peaks_indexed.h5ad \
  --drop-unmapped

# 2) ALS imputation
export EMB_DIR=embeddings/atac_embs_dim.zarr
export INPUT=data/peaks_indexed.h5ad
export OUTPUT=output/peaks_imputed_ALS.h5ad
bash scripts/run_impute.sh

# 3) Optional clustering metrics (needs obs['cell_type'])
# python scripts/evaluate_clustering.py --help
```

## Load results

```python
import scanpy as sc
ad = sc.read_h5ad("output/peaks_imputed_ALS.h5ad")
X = ad.X            # imputed scores (may be negative)
B = ad.obsm["latent"]
Z = ad.varm["topic"]
A = ad.uns["ALS_A"]
```

## Ablation (real / random / shuffled \(E\))

```bash
python regain/impute_als_ablation.py \
  --input data/peaks_indexed.h5ad \
  --output output/ablation_shuffled.h5ad \
  --emb_dir embeddings/atac_embs_dim.zarr \
  --emb_dim 768 \
  --emb_mode shuffled \
  --emb_ablation_seed 42 \
  --topics 64 --lambdaA 1 --lambdaB 1 \
  --als_iters 20 --cg_iters 500 --binary --seed 42
```
