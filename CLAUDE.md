# homelab-homepage

Config for the Homepage dashboard at `http://dash.home` (container on the Docker host, `192.168.20.13`, port 3001). A timer on that host pulls this repo every 5 minutes and applies it, so **pushing to `main` is the deploy**. There is no other step.

## How to make a change

- Add, remove or edit tiles: `config/services.yaml`
- Title, theme, layout of the groups: `config/settings.yaml`
- Container settings (port, allowed hosts): `docker-compose.yml`
- Commit and push to `main`. The dashboard updates within 5 minutes (`sudo homepage-deploy` on the Docker host forces it).

## Rules

- **This repo is public.** Never commit secrets (API keys, tokens, passwords, the ntfy URL, SSH keys) or anything you wouldn't post publicly. `.gitignore` blocks `*.env`, but check the diff anyway. Widgets that need keys use `{{HOMEPAGE_VAR_NAME}}` in the YAML, with the value in an env file on the server.
- It's public on purpose, so the server can pull it with no key or login. The only thing it reveals is the lab's private addresses and service names, which aren't reachable from outside the network. Don't add anything more sensitive than that (no public IP, no Tailscale name, no domain names you own).
- Addresses follow the lab plan: Lab is `192.168.20.0/24` (Proxmox `.10`, Pi-hole `.11`, Docker host `.13`); the NAS is `192.168.1.9` until it moves to Lab (`.15`). Names are `<service>.home`, served by Nginx Proxy Manager.
- Each service is one tile: `icon` (a name from the dashboard-icons set), `href` (the `.home` name), and `siteMonitor` (direct IP and port, for the status dot). Drop `siteMonitor` for HTTPS backends with self-signed certificates if the dot stays red.
- Keep YAML to two-space indents, no tabs. GitHub Actions (`checks.yml`) lints it, and the server refuses to apply a commit that doesn't parse, keeping the last good version.

## Layout

- `config/`: mounted into the container as `/app/config`
- `docker-compose.yml`: the Homepage container
- `deploy/homepage-deploy`: the pull-and-apply script (installed to `/usr/local/bin`)
- `deploy/systemd/`: the 5-minute timer
- `deploy/bootstrap.sh`: one-time setup on the Docker host
- `.github/workflows/checks.yml`: lint and validation

A new service also needs an entry in Nginx Proxy Manager (done in its web UI, not in this repo) before its `.home` link works.
