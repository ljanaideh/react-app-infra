# Local Atlantis (Docker + ngrok)

This repo’s [atlantis.yaml](../atlantis.yaml) runs **Terragrunt**. The official Atlantis image does not include Terragrunt, so use the included **Dockerfile** or install Terragrunt yourself.

## One-time setup

1. Copy the env template and fill in secrets (file is gitignored):

   ```bash
   cp scripts/.env.atlantis.example scripts/.env.atlantis.local
   ```

2. Edit `scripts/.env.atlantis.local`:
   - **ATLANTIS_GH_USER** / **ATLANTIS_GH_TOKEN** — GitHub user and a [PAT](https://github.com/settings/tokens) with repo access (needs **`repo`** or **`admin:repo_hook`** if you use webhook auto-update).
   - **ATLANTIS_GH_WEBHOOK_SECRET** — optional; if set, use the **same** value in the GitHub webhook **Secret** field.
   - **ATLANTIS_REPO_ALLOWLIST** — e.g. `github.com/your-org/react-app-infra`.
   - **GITHUB_WEBHOOK_ID** — optional; numeric id from `https://github.com/org/repo/settings/hooks/<id>` for **`--update-github-webhook`**.
   - **ATLANTIS_DEFAULT_TF_VERSION** — should satisfy modules (Terraform &gt;= 1.6).
   - **AWS_*** / **TF_STATE_BUCKET** — same as local Terragrunt; the script mounts `~/.aws` read-only into the container.

3. Install [ngrok](https://ngrok.com/) if you want GitHub to reach your laptop (optional if you only use the script’s built-in ngrok).

## Run Atlantis

From the repo root:

```bash
chmod +x scripts/run-atlantis-local.sh
./scripts/run-atlantis-local.sh
```

This builds **react-app-infra-atlantis:local** (Atlantis + Terragrunt) and starts container **atlantis-local** on port **4141** (override with **ATLANTIS_PORT**).

- **Stop:** `./scripts/run-atlantis-local.sh stop` (stops Atlantis **and** ngrok if this script started it)
- **Logs:** `./scripts/run-atlantis-local.sh logs`

## ngrok from the script

With **`ngrok` on your PATH**, you can start Atlantis **and** ngrok in one go:

```bash
./scripts/run-atlantis-local.sh --with-ngrok
# or: ATLANTIS_WITH_NGROK=1 ./scripts/run-atlantis-local.sh
```

The script starts **`ngrok http $ATLANTIS_PORT`**, polls **http://127.0.0.1:4040/api/tunnels**, and prints the **https** public URL plus **`/events`** for the GitHub webhook. It also writes the ngrok PID to **`scripts/.atlantis-ngrok.pid`** (gitignored) and logs to **`scripts/.atlantis-ngrok.log`**.

Then:

1. Set **ATLANTIS_ATLANTIS_URL** in `scripts/.env.atlantis.local` to that **https** URL (for correct links in PR comments).
2. Run **`./scripts/run-atlantis-local.sh stop`** then **`./scripts/run-atlantis-local.sh --with-ngrok`** so Atlantis picks up the new URL.

GitHub → **Settings → Webhooks**:

- **Payload URL:** `https://<ngrok-host>/events`
- **Content type:** `application/json`
- **Secret:** optional; must match **ATLANTIS_GH_WEBHOOK_SECRET** if you use one
- **Events:** e.g. **Pull requests**, **Issue comment** (if using `atlantis` on PR comments)

Free ngrok URLs change when you restart ngrok; update **ATLANTIS_ATLANTIS_URL** and the webhook when the host changes (or use auto-update below).

## Auto-update GitHub webhook URL

If **`GITHUB_WEBHOOK_ID`** is set in `scripts/.env.atlantis.local` (and your token can PATCH hooks), you can update the webhook’s **Payload URL** to match the current ngrok URL in one command:

```bash
./scripts/run-atlantis-local.sh --with-ngrok --update-github-webhook
# or: ATLANTIS_UPDATE_GITHUB_WEBHOOK=1 ATLANTIS_WITH_NGROK=1 ./scripts/run-atlantis-local.sh
```

This calls the GitHub API: **`PATCH /repos/{owner}/{repo}/hooks/{GITHUB_WEBHOOK_ID}`** with **`config.url`** = **`{ngrok https URL}/events`**. Optional **`GITHUB_WEBHOOK_TOKEN`** overrides **`ATLANTIS_GH_TOKEN`** for that request. If **`ATLANTIS_GH_WEBHOOK_SECRET`** is non-empty, it is sent in **`config.secret`**.

## Troubleshooting

**`permission denied` on `/home/atlantis/.atlantis/bin`**

Do not mount a Docker volume on `/home/atlantis/.atlantis` unless the mount is writable by the **atlantis** user (often UID **100**). The default script does **not** mount that path so Atlantis can store Terraform binaries inside the container. Remove any leftover volume: `docker volume rm atlantis-local-data`.

**ngrok: `failed to open private leg` / `dial tcp 127.0.0.1:4141: connect: connection refused`**

ngrok is forwarding to your machine, but nothing is accepting connections on that port yet (or the Atlantis container exited). The script waits for the port before starting ngrok; if you still see this, run **`docker ps`** (look for **atlantis-local**), **`curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4141/`**, and **`docker logs atlantis-local`**.

## Security

Never commit `scripts/.env.atlantis.local`. Rotate tokens if exposed.
