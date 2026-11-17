# Demo (toy smoke-test)

Tiny self-contained subset so you can run ChromBERT-REGAIN **without** downloading the full ~9.5 GB HuggingFace embedding.

| File | Role |
|------|------|
| `demo_peaks.h5ad` | ~200 cells × ~3000 peaks (Tcells subset); sparse `X`; `obs['cell_type']` |
| `demo_emb.zarr/full` | Matching mini embedding `(n_peaks, 768)` float16 |
| `run_demo.sh` | Fast ALS smoke-test (small `topics` / iters) |
| `output/` | Created by the demo run (gitignored) |

## Index remapping

`impute_als.py` loads `E = E_src[adata.varm['indices']]`. For this toy package:

- `varm['indices']` is remapped to contiguous `0 .. n_peaks-1` so it indexes into `demo_emb.zarr`
- Original ChromBERT genomic-bin IDs are kept in `varm['chrombert_bin_index']` for provenance

This is **not** suitable for scientific conclusions — only a pipeline smoke-test.

## Full-scale embeddings

For real analyses, download the genome-wide ChromBERT region embeddings:

https://huggingface.co/datasets/llzzhh0512/ChromBERT-REGAIN

Point `--emb_dir` at the extracted `atac_embs_dim.zarr` (hg38) or `atac_embs_dim_mm10.zarr` (mm10), and use an `.h5ad` whose `varm['indices']` are true ChromBERT bin indices (see `scripts/prepare_peak_indices.py`).

## Run

```bash
# from repo root, with dependencies installed
bash examples/demo/run_demo.sh
```

Expected output: `examples/demo/output/demo_imputed.h5ad`.
