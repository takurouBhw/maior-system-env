#!/bin/sh

cd /var/www/html
# プロジェクトディレクトリが存在しない場合はlaravelを新規インストール
if [ ! -d "/var/www/html/${PROJECT_NAME}" ]; then
	composer create-project laravel/laravel "${PROJECT_NAME}" "${LARAVEL_VERSION}" --prefer-dist
fi
