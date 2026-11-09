# Minimal usage example

## Prerequisites

1. Install packages from `requirements.txt` and install `bedtools`
2. Prepare a ChromBERT embedding zarr (see `docs/embedding.md`)
3. Place the genomic bin BED files under `annotations/`

## Steps

```bash
# 1) Write varm['indices'] for the peak matrix
# hg38:
BIN_BED=annotations/hg38_6k_1kb_region.bed
# mm10:
# BIN_BED=annotations/mm10_5k_1kb_region.bed

python scripts/prepare_peak_indices.py \
  --input data/raw_peaks.h5ad \
  --bins "$BIN_BED" \
  --output data/peaks_indexed.h5ad \
  --drop-unmapped

# 2) ALS imputation
export EMB_DIR=/path/to/atac_embs_dim.zarr
export INPUT=data/peaks_indexed.h5ad
export OUTPUT=output/peaks_imputed_ALS.h5ad
bash scripts/run_impute.sh

# 3) (Optional) clustering metrics; requires obs['cell_type']
# Call scripts/evaluate_clustering.py with its CLI arguments
```

## Load results

```python
import scanpy as sc
ad = sc.read_h5ad("output/peaks_imputed_ALS.h5ad")
X = ad.X            # imputed scores
B = ad.obsm["latent"]
Z = ad.varm["topic"]
A = ad.uns["ALS_A"]
```

## Ablation (real / random / shuffled E)

```bash
python regain/impute_als_ablation.py \
  --input data/peaks_indexed.h5ad \
  --output output/ablation_shuffled.h5ad \
  --emb_dir $EMB_DIR \
  --emb_dim 768 \
  --emb_mode shuffled \
  --emb_ablation_seed 42 \
  --topics 64 --lambdaA 1 --lambdaB 1 \
  --als_iters 20 --cg_iters 500 --binary --seed 42
```
