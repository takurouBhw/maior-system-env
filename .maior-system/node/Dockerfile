FROM node:18.17.0-buster

# コンテナ内の環境変数を定義するための引数
ARG PROJECT_NAME
ARG PASSWORD
ARG USER

# 環境変数を設定する
ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}

# 一般ユーザーを追加
RUN useradd -m ${USER} --uid 1001
RUN gpasswd -a ${USER} sudo
RUN echo "${USER}:${PASSWORD}" | chpasswd

# ディレクトリを変更してからユーザーを切り替える
WORKDIR /var/www/html

# 一般ユーザーに切り替える
USER ${USER}

# ポートを公開
EXPOSE 3000
EXPOSE 1337
