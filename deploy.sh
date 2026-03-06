# pull from github

umask 0002

git pull origin main

# NodeJS support, e.g. for vite
# npm install
# npm run build

composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# deployment best practices by craftcms docs:
# https://craftcms.com/knowledge-base/deployment-best-practices
php craft update/composer-install --interactive=0
php craft migrate/all --no-content --interactive=0
php craft project-config/apply
php craft migrate --track=content --interactive=0

# Re-apply writable permissions for Apache/PHP (run via bash; no chmod +x needed)
bash ./scripts/set-craft-permissions.sh "$(pwd)"

echo "🚀 Application deployed!"
