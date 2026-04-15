# Phase 1 — EmDash + observability locally

Validate the app and Docker stack **before** adding a `dev-emdash` Terragrunt env.

Upstream: [ljanaideh/emdash-professionals-demo](https://github.com/ljanaideh/emdash-professionals-demo).

## Prerequisites

- Node 20+, **pnpm** (`corepack enable`)
- **Docker** with Compose v2

## 1. Clone

```bash
git clone https://github.com/ljanaideh/emdash-professionals-demo.git
cd emdash-professionals-demo
```

## 2. Install

```bash
corepack enable
pnpm install
```

## 3. Build workspace packages (required before the demo app)

The demo imports workspace packages (`@emdash-cms/*`). Build them once:

```bash
pnpm run build
```

Without this, `pnpm --filter emdash-demo build` fails resolving packages like `@emdash-cms/plugin-audit-log`.

## 4. Observability stack (Grafana + Loki + OTel)

```bash
cd otel_grafana_stack_fixed
docker compose up -d
docker compose ps
```

- **Grafana:** http://localhost:3000 (login per upstream README, often `admin` / `admin`)
- **Loki:** http://localhost:3100  
- **OTel:** gRPC `4317`, HTTP `4318`

## 5. EmDash — dev server

From repo root:

```bash
pnpm --filter emdash-demo dev
```

- Site: http://localhost:4321  
- Admin: http://localhost:4321/_emdash/admin  

## 6. EmDash — production build (containerization prep)

```bash
pnpm --filter emdash-demo build
cd demos/simple
PORT=4321 HOST=0.0.0.0 NODE_ENV=production node ./dist/server/entry.mjs
```

SQLite and uploads live under `demos/simple/` (`data.db`, `uploads/`).

## 7. Stop

```bash
cd otel_grafana_stack_fixed && docker compose down
```

Stop the Node dev server with `Ctrl+C`.

## Optional: `pnpm approve-builds`

If installs warn about ignored build scripts (`sharp`, etc.), run `pnpm approve-builds` per pnpm’s prompt if you need those native deps locally.

## Next — Phase 2 (container)

See [docker/emdash-demo/README.md](../docker/emdash-demo/README.md) and [scripts/emdash-docker-build.sh](../scripts/emdash-docker-build.sh).
