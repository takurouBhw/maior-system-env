#!/bin/sh

#### docker-compse.ymlの.envファイルを生成するスクリプト ####

# .envrcファイルが存在しない場合は新規作成
if [ ! -f .envrc ]; then
  cat .envrc.example > .envrc
  echo -e "Created a new .env file for docker-compose. \n Please write the settings in the .env file."
  return;
fi

# .envrcを読み込みdocker-compse.ymlの.envファイルを生成する
source .envrc

PROJECT_ROOT=$(pwd)
# このディレクトリパス以下がdocker-composeの資材置き場
DEVCONTAINER_DIR_PATH="${PROJECT_ROOT}/.devcontainer"

# .devcontainerが存在しない場合は既に初期化処理を実行済み
if [ -d "$DEVCONTAINER_DIR_PATH" ]; then
	mv "$DEVCONTAINER_DIR_PATH" "${PROJECT_ROOT}/.${PROJECT_NAME}"
  DEVCONTAINER_DIR_PATH="${PROJECT_ROOT}/.${PROJECT_NAME}"
fi

INIT_DB_PATH="${DEVCONTAINER_DIR_PATH}/db/init"
INIT_SQLFILE_PATH="${INIT_DB_PATH}/init.sql"
DOCKER_ENVFILE_PATH="${DEVCONTAINER_DIR_PATH}/.env"
DB_DATA_PATH="${DEVCONTAINER_DIR_PATH}/db/data"

# db/initディレクトリが存在する場合は削除
if [  -d $INIT_DB_PATH ]; then
  rm -rf $INIT_DB_PATH
fi
# db/initディレクトリ作成
mkdir "$INIT_DB_PATH"

# docker-composeの.envファイルが存在しない場合は作成
if [ ! -f $DOCKER_ENVFILE_PATH ]; then
  echo "PROJECT_NAME=${PROJECT_NAME}" > $DOCKER_ENVFILE_PATH
  echo "NODEJS_VERSION=${NODEJS_VERSION}" >> $DOCKER_ENVFILE_PATH
	echo "LARAVEL_VERSION=${LARAVEL_VERSION}" >> $DOCKER_ENVFILE_PATH
  echo "APP_NAME=${APP_NAME}" >> $DOCKER_ENVFILE_PATH
  echo "DB_DATABASE=${DB_DATABASE}" >> $DOCKER_ENVFILE_PATH
  echo "DB_USER=${DB_USER}" >> $DOCKER_ENVFILE_PATH
  echo "USER=${USER}" >> $DOCKER_ENVFILE_PATH
  echo "DB_PASSWORD=${DB_PASSWORD}" >> $DOCKER_ENVFILE_PATH
  echo "PROXY_PUBLIC_PORT=${PROXY_PUBLIC_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "PROXY_SSH_PORT=${PROXY_SSH_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "VITE_PORT=${VITE_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "REACT_PORT=${REACT_PORT}" >> $DOCKER_ENVFILE_PATH 
  echo "PHP_SERVE_PORT=${PHP_SERVE_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "PHP_MYADMIN_PUBLIC_PORT=${PHP_MYADMIN_PUBLIC_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "NODE_PORT=${NODE_PORT}" >> $DOCKER_ENVFILE_PATH
  echo "MEMORY_LIMIT=${MEMORY_LIMIT}" >> $DOCKER_ENVFILE_PATH
  echo "UPLOAD_LIMIT=${UPLOAD_LIMIT}" >> $DOCKER_ENVFILE_PATH

fi

# 初回に作成するsqlファイルを格納するディレクトリが存在しない場合
if [ ! -d $INIT_DIR_PATH ]; then
  mkdir $INIT_DIR_PATH
fi

# sqlファイル作成
echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" > $INIT_SQLFILE_PATH
rm -rf "$DB_DATA_PATH"

# test用sqlファイル作成
echo "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}_testing CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" >> $INIT_SQLFILE_PATH
