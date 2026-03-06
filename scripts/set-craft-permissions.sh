#!/usr/bin/env bash
set -euo pipefail

# Ubuntu + Apache/Craft defaults:
# - Apache/PHP runs as user/group: www-data
# - Writable paths for this deployment:
#   storage/, web/cpresources/, config/, config/license.key

APP_PATH="${1:-$(pwd)}"
WEB_USER="www-data"
WEB_GROUP="www-data"

cd "$APP_PATH"

mkdir -p storage web/cpresources config
touch config/license.key

echo "Setting Craft permissions in: $(pwd)"
echo "Using web server user/group: ${WEB_USER}:${WEB_GROUP}"

# Ownership for writable paths
chown -R "${WEB_USER}:${WEB_GROUP}" storage web/cpresources config

# Directories: group writable + setgid so new files keep group
find storage web/cpresources config -type d -exec chmod 2775 {} \;

# Files: group writable
find storage web/cpresources config -type f -exec chmod 664 {} \;
chmod 664 config/license.key

# Keep permissions on new files (if ACL tools are installed)
if command -v setfacl >/dev/null 2>&1; then
  setfacl -R -m g:${WEB_GROUP}:rwX storage web/cpresources config
  setfacl -R -d -m g:${WEB_GROUP}:rwX storage web/cpresources config
  setfacl -m g:${WEB_GROUP}:rw config/license.key
else
  echo "ACL not installed; using setgid only."
  echo "For deploys without ACL, run commands with: umask 0002"
fi

echo "Done."
