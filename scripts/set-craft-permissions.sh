#!/usr/bin/env bash
set -euo pipefail

# Ubuntu + Apache/Craft defaults:
# - Apache/PHP runs as group: www-data
# - Required writable paths for Craft:
#   storage/, web/cpresources/, config/license.key

APP_PATH="${1:-$(pwd)}"
WEB_GROUP="www-data"

cd "$APP_PATH"

mkdir -p storage web/cpresources config
touch config/license.key

echo "Setting Craft permissions in: $(pwd)"
echo "Using web server group: ${WEB_GROUP}"

# Group ownership for writable paths
chgrp -R "$WEB_GROUP" storage web/cpresources config/license.key

# Directories: group writable + setgid so new files keep group
find storage web/cpresources -type d -exec chmod 2775 {} \;

# Files: group writable
find storage web/cpresources -type f -exec chmod 664 {} \;
chmod 664 config/license.key

# Keep permissions on new files (if ACL tools are installed)
if command -v setfacl >/dev/null 2>&1; then
  setfacl -R -m g:${WEB_GROUP}:rwX storage web/cpresources
  setfacl -R -d -m g:${WEB_GROUP}:rwX storage web/cpresources
  setfacl -m g:${WEB_GROUP}:rw config/license.key
else
  echo "Tip: install acl package to persist default write ACLs: sudo apt install -y acl"
fi

echo "Done."
