#!/usr/bin/env bash
set -euo pipefail

# Ubuntu + Apache/Craft defaults:
# - Apache/PHP runs as user/group: www-data
# - Writable paths for this deployment:
#   storage/, web/cpresources/, config/ (dir), config/license.key

APP_PATH="${1:-$(pwd)}"
WEB_USER="www-data"
WEB_GROUP="www-data"

cd "$APP_PATH"

mkdir -p storage web/cpresources config
[[ -f config/license.key ]] || touch config/license.key

echo "Setting Craft permissions in: $(pwd)"
echo "Using web server user/group: ${WEB_USER}:${WEB_GROUP}"

# Ownership for writable paths (only as root)
if [[ "$(id -u)" -eq 0 ]]; then
  chown -R "${WEB_USER}:${WEB_GROUP}" storage web/cpresources
  chown "${WEB_USER}:${WEB_GROUP}" config || true
  chown "${WEB_USER}:${WEB_GROUP}" config/license.key || true
else
  echo "Not running as root; skipping chown."
  if chgrp -R "${WEB_GROUP}" storage web/cpresources 2>/dev/null; then
    echo "Applied group ${WEB_GROUP} via chgrp."
  else
    echo "Could not chgrp to ${WEB_GROUP}; continuing with chmod only."
  fi
  chgrp "${WEB_GROUP}" config 2>/dev/null || true
  chgrp "${WEB_GROUP}" config/license.key 2>/dev/null || true
fi

# Directories: group writable + setgid so new files keep group
find storage web/cpresources -type d -exec chmod 2775 {} \; || true
chmod 2775 config || true

# Files: group writable
find storage web/cpresources -type f -exec chmod 664 {} \; || true
chmod 664 config/license.key || true

# No ACL dependency.
echo "Using setgid + umask strategy (no ACL)."
echo "Run deploys with: umask 0002"

echo "Done."
