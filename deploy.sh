# pull from github

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


echo "🚀 Application deployed!"
