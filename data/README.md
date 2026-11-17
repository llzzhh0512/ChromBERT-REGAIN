# Data directory (local)

Place your own peak matrices here (gitignored), e.g.:

```text
data/raw_peaks.h5ad
data/peaks_indexed.h5ad
```

Genome-wide ChromBERT embeddings go under `../embeddings/` after:

```bash
bash scripts/download_embeddings.sh
```

Source: https://huggingface.co/datasets/llzzhh0512/ChromBERT-REGAIN

For an offline smoke-test, use `examples/demo/` instead of this folder.
