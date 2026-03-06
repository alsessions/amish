#!/usr/bin/env bash
set -euo pipefail

# One-time Craft permissions setup for Ubuntu + Apache (www-data).
# Run as root:
#   sudo bash scripts/set-craft-permissions.sh /var/www/jeff.owlwebdev.com

APP_PATH="${1:-$(pwd)}"
WEB_USER="www-data"
WEB_GROUP="www-data"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo bash $0 <app-path>" >&2
  exit 1
fi

cd "$APP_PATH"
mkdir -p storage web/cpresources config
[[ -f config/license.key ]] || touch config/license.key

# Writable by PHP/Apache
chown -R "${WEB_USER}:${WEB_GROUP}" storage web/cpresources
chown "${WEB_USER}:${WEB_GROUP}" config config/license.key

# Directory/file modes
find storage web/cpresources -type d -exec chmod 2775 {} \;
find storage web/cpresources -type f -exec chmod 664 {} \;
chmod 2775 config
chmod 664 config/license.key

echo "Done. Writable paths set for ${WEB_USER}:${WEB_GROUP}."
