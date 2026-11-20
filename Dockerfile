# Build the frontend assets separately so production does not need Node.js.
FROM node:22-alpine AS frontend
WORKDIR /app
COPY package.json package-lock.json ./
COPY .npmrc ./
RUN npm ci --no-audit --no-fund
COPY resources ./resources
COPY public ./public
COPY vite.config.js ./
RUN npm run build

FROM php:8.4-fpm AS app

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx unzip libzip-dev libpq-dev \
 && docker-php-ext-install bcmath pdo_mysql pdo_pgsql zip \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html

COPY . .
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
 && mkdir -p database storage/app/private storage/app/public storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs \
 && chown -R www-data:www-data storage bootstrap/cache database

COPY docker/nginx.conf /etc/nginx/sites-available/default
COPY docker/start.sh /usr/local/bin/start.sh
COPY --from=frontend /app/public/build ./public/build
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 10000
CMD ["/usr/local/bin/start.sh"]
