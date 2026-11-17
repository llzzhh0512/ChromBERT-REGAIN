# ChromBERT region embedding \(E\)

## Where to download (recommended)

Genome-wide embeddings are published on Hugging Face:

**https://huggingface.co/datasets/llzzhh0512/ChromBERT-REGAIN**

| Artifact | Genome | Approx. size | Local name after extract |
|----------|--------|--------------|--------------------------|
| `atac_embs_dim.tar` | hg38 | ~9.5 GB | `atac_embs_dim.zarr/` |

```bash
# from repo root
bash scripts/download_embeddings.sh
# → embeddings/atac_embs_dim.zarr/full
```

For a **tiny offline smoke-test** that does **not** need this download, use `examples/demo/` (mini zarr already bundled).

Mouse (`atac_embs_dim_mm10.zarr`) will be listed on the same HF dataset page when published.

## Array layout

| Array | Shape (hg38) | dtype | When used |
|-------|--------------|-------|-----------|
| `full` | 2,137,894 × 768 | float16 | `--emb_dim 768` (default / production) |
| `PCA/32` etc. | 2,137,894 × {32,50,100} | float64 | `--emb_dim 32` (etc.) |

Mouse `full` is about 1,531,858 × 768.

`impute_als.py` selects:

```text
emb_dim == 768 → {emb_dir}/full
else           → {emb_dir}/PCA/{emb_dim}
E = E_src[adata.varm['indices']]
```

Metadata-only stubs (shapes, no values) live under `docs/embedding_zarr_meta/` for reference.

## Peak ↔ bin alignment

Use `scripts/prepare_peak_indices.py` to map each peak center to a ChromBERT `bin_index`, writing `adata.varm['indices']`.

Bin BEDs shipped in this repo:

| Genome | Path | #bins |
|--------|------|------:|
| hg38 | `annotations/hg38_6k_1kb_region.bed` | 2,137,894 |
| mm10 | `annotations/mm10_5k_1kb_region.bed` | 1,530,871 |

Format: `chrom  start  end  bin_index` (no header). hg38 rows match zarr `full` axis 0.

## Provenance note

Embeddings are ChromBERT pretrained artifacts (regulatory-factor ChIP-seq co-association). Do not describe them as a sequence-only language model without verification.
