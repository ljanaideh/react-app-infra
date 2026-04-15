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

From **inside** `emdash-professionals-demo`:

```bash
docker build \
  -f /path/to/react-app-infra/docker/emdash-demo/Dockerfile \
  -t emdash-demo:local \
  .
```

**Fargate / Graviton (linux/arm64):**

```bash
docker buildx build --platform linux/arm64 \
  -f /path/to/react-app-infra/docker/emdash-demo/Dockerfile \
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

```bash
./scripts/emdash-docker-build.sh
```

Set **`EMDASH_SRC`** to your clone path if it is not `../emdash-professionals-demo`.

## Docs

- Phase 1 (local, no image): [docs/emdash-local-phase1.md](../../docs/emdash-local-phase1.md)
