# EmDash container (phase 2)

Docker assets for **[emdash-professionals-demo](https://github.com/ljanaideh/emdash-professionals-demo)** live here; the **app source stays in that repo**. The image build **context** is always the **clone root** of EmDash, not `react-app-infra`.

## 1. Clone EmDash (if needed)

```bash
git clone https://github.com/ljanaideh/emdash-professionals-demo.git
cd emdash-professionals-demo
```

## 2. Optional: shrink the build context

```bash
cp /path/to/react-app-infra/docker/emdash-demo/dockerignore.example .dockerignore
```

## 3. Build

Use your **real** paths (not the literal string `/path/to/...`). Example: clone lives in `~/Downloads/emdash-professionals-demo`.

From **inside** `emdash-professionals-demo`:

```bash
docker build \
  -f ~/Downloads/react-app-infra/docker/emdash-demo/Dockerfile \
  -t emdash-demo:local \
  .
```

**Fargate / Graviton (linux/arm64):**

```bash
docker buildx build --platform linux/arm64 \
  -f ~/Downloads/react-app-infra/docker/emdash-demo/Dockerfile \
  -t emdash-demo:local \
  --load \
  .
```

## 4. Run

```bash
docker run --rm -p 4321:4321 emdash-demo:local
```

- Site: http://localhost:4321  
- SQLite + uploads live under `/app/demos/simple` in the container; add **`-v`** for persistence if needed.

## 5. Helper script (from `react-app-infra` root)

If the clone is **next to** this repo (`../emdash-professionals-demo`), run:

```bash
./scripts/emdash-docker-build.sh
```

Otherwise set the **absolute or home path** to the EmDash clone (must contain `package.json`):

```bash
EMDASH_SRC=~/Downloads/emdash-professionals-demo ./scripts/emdash-docker-build.sh
```

Do **not** use a placeholder like `/path/to/emdash-professionals-demo`.

## 6. Deploy on AWS (this repo)

Separate Fargate stack **`environments/dev-emdash`** (own VPC + ECR **`dev-emdash`**, container port **4321**). See **[docs/terragrunt-dev-emdash.md](../../docs/terragrunt-dev-emdash.md)** and:

```bash
EMDASH_SRC=~/Downloads/emdash-professionals-demo ./scripts/emdash-docker-push-ecr.sh
```

## Docs

- Phase 1 (local, no image): [docs/emdash-local-phase1.md](../../docs/emdash-local-phase1.md)
