# REGAIN

Sparse scATAC-seq accessibility imputation with a fixed ChromBERT region embedding \(E\) that constrains low-rank reconstruction:

\[
Y \approx E A B
\]

<img width="1600" height="900" alt="REGAIN model overview" src="https://github.com/llzzhh0512/REGAIN/blob/main/docs/model.svg" />

This repository is a **GitHub release package** extracted from the full analysis project. It includes model code, key scripts, and dataset documentation only — large matrices, fragments, and checkpoints are not included.

---

## Repository layout

```
REGAIN/
├── README.md
├── requirements.txt
├── .gitignore
├── regain/                 # core model
│   ├── impute_als.py       # production ALS (recommended)
│   ├── impute_als_ablation.py  # real / random / shuffled E ablation
│   └── impute_ridge.py     # earlier ridge baseline with the same E
├── scripts/
│   ├── run_impute.sh       # CLI example
│   ├── prepare_peak_indices.py  # peak → ChromBERT bin index
│   └── evaluate_clustering.py   # ARI/NMI and related metrics
├── configs/
│   └── default_impute.yaml
├── docs/
│   ├── model.md            # model equations and implementation notes
│   ├── datasets.md         # datasets and how to obtain them
│   └── embedding.md        # E (zarr) description
├── annotations/            # ChromBERT bin BEDs (hg38 / mm10)
│   ├── hg38_6k_1kb_region.bed
│   └── mm10_5k_1kb_region.bed
└── examples/
    └── minimal_usage.md
```

---

## Quick start

### 1. Environment

```bash
conda create -n regain python=3.10 -y
conda activate regain
pip install -r requirements.txt
# Also requires bedtools (for peak index mapping)
```

### 2. Input requirements

Input `.h5ad` (cells × peaks) should contain:

- `adata.X`: sparse/dense peak counts (or binary)
- `adata.varm['indices']`: integer ChromBERT genomic-bin index for each peak  
  (generate with `scripts/prepare_peak_indices.py`)

Bin BEDs (shipped with this repo):

- hg38: `annotations/hg38_6k_1kb_region.bed`
- mm10: `annotations/mm10_5k_1kb_region.bed`

You also need a ChromBERT region-embedding zarr directory (with `full` or `PCA/<dim>`).

### 3. Run imputation

```bash
python -u regain/impute_als.py \
  --input  data/10XPBMC.h5ad \
  --output output/10XPBMC_imputed_ALS.h5ad \
  --emb_dir /path/to/atac_embs_dim.zarr \
  --emb_dim 768 \
  --topics 128 \
  --lambdaA 1 \
  --lambdaB 0.1 \
  --als_iters 20 \
  --cg_iters 500 \
  --binary \
  --seed 42
```

Or edit and run:

```bash
bash scripts/run_impute.sh
```

### 4. Output fields

| Field | Meaning |
|------|------|
| `adata.X` | Imputed relative accessibility scores (float16; **can be negative**) |
| `adata.obsm['latent']` | Cell embeddings \(B^\top\) |
| `adata.varm['topic']` | Region embeddings \(EA\) |
| `adata.uns['ALS_A']` | Factor \(A\) |

For unseen-peak extrapolation: `E_test @ ALS_A @ latent.T`.

---

## Citation and prior source

- This method: **REGAIN** (fixed \(E\) + ALS low-rank reconstruction)
- Region embeddings come from ChromBERT pretrained artifacts (published ChromBERT is primarily pretrained on regulatory-factor ChIP-seq co-association)

---
