#!/bin/bash
# composer update

echo "---------- demarrage init_app_entrypoint"

composer install
npm install
npm run build

if [ "$PHP_SERVER" = "1" ]; then
    APP_KEY=$(grep "^APP_KEY=" .env | cut -d '=' -f2- | tr -d '[:space:]')
    
    if [ -z "$APP_KEY" ]; then
        echo "APP_KEY empty, generate new key..."
        php artisan key:generate
    else
        echo "APP_KEY existe déjà"
    fi
    
    echo "Vérification de la table user..."
    TABLE_EXISTS=$(php artisan tinker --execute="echo \Illuminate\Support\Facades\Schema::hasTable('users') ? '1' : '0';")
    
    if [ "$TABLE_EXISTS" = "0" ]; then
        echo "Table 'users' n'existe pas, exécution des migrations..."
        php artisan migrate:fresh --seed
    else
        echo "Table 'users' existe déjà, pas de migration"
    fi
fi

echo "----------- fin init_app_entrypoint"

exec "$@"
