#!/bin/sh
# One-time setup on the Docker host (the container that runs Homepage).
#
#   git clone https://github.com/gunz0blazin/homelab-homepage.git /tmp/homelab-homepage
#   sudo /tmp/homelab-homepage/deploy/bootstrap.sh
#
# Installs git and the YAML checker, installs the deploy command and the 5-minute
# timer, and runs the first deploy. The repo is public, so no key or login is needed.
# Safe to run again: it skips what's already done and never overwrites a setting.
set -eu

REPO_URL_DEFAULT=https://github.com/gunz0blazin/homelab-homepage.git
CONF=/etc/homepage-deploy
HERE=$(cd "$(dirname "$0")" && pwd)

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo." >&2; exit 1
fi

echo "==> Packages"
apt-get update -qq
apt-get install -y git curl python3-yaml

command -v docker >/dev/null 2>&1 || { echo "Docker isn't installed on this machine." >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "The 'docker compose' plugin is missing." >&2; exit 1; }

echo "==> Settings in $CONF"
install -d -m 0700 "$CONF"
if [ ! -e "$CONF/deploy.env" ]; then
  cat > "$CONF/deploy.env" <<EOF
# Which repo and branch this machine deploys.
REPO_URL=${REPO_URL:-$REPO_URL_DEFAULT}
BRANCH=${BRANCH:-main}
EOF
  chmod 0600 "$CONF/deploy.env"
fi

if [ ! -e "$CONF/ntfy_url" ]; then
  printf '    ntfy topic URL for deploy notifications (Enter to skip): '
  read -r ntfy
  [ -n "$ntfy" ] && { printf '%s' "$ntfy" > "$CONF/ntfy_url"; chmod 0600 "$CONF/ntfy_url"; }
fi

echo "==> Deploy command and timer"
install -m 0755 "$HERE/homepage-deploy" /usr/local/bin/homepage-deploy
install -m 0644 "$HERE/systemd/homepage-deploy.service" /etc/systemd/system/
install -m 0644 "$HERE/systemd/homepage-deploy.timer" /etc/systemd/system/
systemctl daemon-reload

echo "==> First deploy"
/usr/local/bin/homepage-deploy
systemctl enable --now homepage-deploy.timer

echo
echo "Done. The dashboard now updates within 5 minutes of a push to the repo."
echo "  Watch it:   journalctl -u homepage-deploy -f"
echo "  Run it now: sudo homepage-deploy"
