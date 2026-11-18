# Model structure and implementation

## Objective

For a peak × cell target matrix $Y$ (typically binarized then TF-IDF):

$\[
Y \approx E W H,\quad
Z = E W\ (\text{peak latent}),\quad
H\ (\text{cell latent})
\]$

Matrix shapes:

$\[
E \in \mathbb{R}^{P \times L},\quad
W \in \mathbb{R}^{L \times K},\quad
H \in \mathbb{R}^{K \times C}
\]$

- $E$: fixed ChromBERT region embedding (not trained)
- $W$, $H$: trainable factors
- Regularization: $\lambda_W \|W\|_F^2 + \lambda_H \|H\|_F^2$

> Legacy code names: `ALS_A` ≡ $W$, `obsm['latent']` ≡ $H^\top$, CLI flags `--lambdaA` / `--lambdaB`.

## Constructing $Y$ (`impute_als.py`)

1. Load h5ad → transpose to peak × cell
2. Optional `--binary`: `(X > 0)`
3. `sklearn.TfidfTransformer(smooth_idf=False, norm='l2')`, then `idf_ -= 1`

## ALS updates

Precompute $G_E = E^\top E$ and $G_Y = E^\top Y$:

$\[
G_E W (H H^\top) + \lambda_W W = G_Y H^\top
\quad\text{(W-step; matrix CG)}
\]$

$\[
(W^\top G_E W + \lambda_H I)\, H = W^\top G_Y
\quad\text{(H-step)}
\]$

Fixed iteration count by default (no early stopping). Initialize $W \sim \mathcal{N}(0,1)\times 0.02$, then solve for $H$ in closed form.

## Output notes

- Predictions are **not** non-negativity constrained (clipping is commented out by default) and **can be negative**
- Scores are relative / TF-IDF-like accessibility — **not** fragment counts, and not probability-calibrated
- If applying `log1p` downstream, handle negatives first

## Extrapolating to unseen peaks

After fitting on training peaks (`ALS_A` ≡ $W$, `latent` ≡ $H^\top`):

```python
imputed_test = (E_test @ W @ H.T).T   # cells × test_peaks
```

For a strict hold-out, test-peak rows must not enter training $Y$, $E^\top E$, TF-IDF, or the loss.

## Related implementations

| File | Role |
|------|------|
| `impute_als.py` | Production ALS |
| `impute_als_ablation.py` | `--emb_mode {real,random,shuffled}` |

## Default hyperparameters (benchmarks)

`emb_dim=768, topics=128, lambdaA=1, lambdaB=0.1, als_iters=20, cg_iters=500, binary`
