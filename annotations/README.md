# ChromBERT genomic bin BED files

| Genome | File in repo | #bins | Format |
|--------|--------------|------:|--------|
| hg38 | `annotations/hg38_6k_1kb_region.bed` | 2,137,894 | `chrom  start  end  bin_index` |
| mm10 | `annotations/mm10_5k_1kb_region.bed` | 1,530,871 | same |

These BEDs define the ChromBERT genomic bins used to index peaks (`adata.varm['indices']`) and to align with embedding rows in `atac_embs_dim*.zarr`.

## Usage

```bash
# human (hg38)
python scripts/prepare_peak_indices.py \
  --input data/peaks.h5ad \
  --bins annotations/hg38_6k_1kb_region.bed \
  --output data/peaks_indexed.h5ad \
  --drop-unmapped

# mouse (mm10)
python scripts/prepare_peak_indices.py \
  --input data/peaks_mm10.h5ad \
  --bins annotations/mm10_5k_1kb_region.bed \
  --output data/peaks_mm10_indexed.h5ad \
  --drop-unmapped
```
