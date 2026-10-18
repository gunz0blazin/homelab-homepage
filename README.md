# homelab-homepage

The Homepage dashboard config for my home lab, deployed by pushing to this repo.

```
push to main  ->  GitHub  ->  Docker host pulls every 5 min  ->  dashboard updates
```

The Docker host makes an outbound connection to GitHub, so nothing needs to be opened on the network and no webhook is needed.

## Changing the dashboard

Edit `config/services.yaml` (tiles) or `config/settings.yaml` (look and layout), commit and push to `main`. Within 5 minutes the dashboard shows it. A commit with broken YAML is skipped and reported (ntfy, if configured), and the dashboard keeps its last good version.

## One-time setup on the Docker host

1. Stop the dashboard that was started by hand, so the port is free:
   ```
   cd ~/homepage && docker compose down
   ```
2. Clone the repo and run the bootstrap. The repo is public, so no key or login is needed.
   ```
   git clone https://github.com/gunz0blazin/homelab-homepage.git /tmp/homelab-homepage
   sudo /tmp/homelab-homepage/deploy/bootstrap.sh
   ```
3. The bootstrap runs the first deploy and starts the timer.

Useful commands on the host:

```
journalctl -u homepage-deploy -f      # watch deploys
sudo homepage-deploy                  # deploy right now
systemctl list-timers homepage-deploy.timer
```

## Files

| Path | What it is |
|---|---|
| `config/` | Homepage's config folder |
| `docker-compose.yml` | the container (port 3001, allowed hosts) |
| `deploy/homepage-deploy` | pulls the repo, validates, applies |
| `deploy/systemd/` | the 5-minute timer |
| `deploy/bootstrap.sh` | one-time host setup |
| `.github/workflows/checks.yml` | YAML lint and compose validation |

No secrets live in this repo. Widget API keys, when added, go in an env file on the host.
