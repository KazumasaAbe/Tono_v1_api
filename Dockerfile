# ベースイメージ
FROM ruby:2.7.1-alpine
# Dockerfile内で使用する変数名を指定
ARG WORKDIR
# Dockerイメージで使用する環境変数を指定
ENV RUNTIME_PACKAGES="linux-headers libxml2-dev make gcc libc-dev nodejs tzdata postgresql-dev postgresql git" \
  DEV_PACKAGES="build-base curl-dev" \
  HOME=/${WORKDIR} \
  LANG=C.UTF-8 \
  TZ=Asia/Tokyo

# ベースイメージに対して何らかのコマンドを実行する場合に使用
RUN echo ${HOME}
# Dockerfileで定義した命令を実行する、コンテナ内の作業ディレクトリパスを指定
WORKDIR ${HOME}

# 「*はGemfileで始まるファイル名を全てコピーする」という指定
# ./ WORKDIRの直下にコピー
COPY Gemfile* ./

# Alpine Linuxのコマンド
# 用可能なパッケージの最新リストを取得するためのコマンド
RUN apk update && \
  # インストールされているパッケージをアップグレード
  apk upgrade && \
  # パッケージをインストールするコマンド
  # --no-cache ローカルにキャッシュしないようにする、addコマンドのオプション
  apk add --no-cache ${RUNTIME_PACKAGES} && \
  # --virtual このオプションを付けてインストールしたパッケージは、一まとめにされ、新たなパッケージとして扱うことができ
  apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
  # Railsに必要なGemをインストールするためにbundle installコマンドを実行
  bundle install -j4 && \
  # パッケージを削除するコマンド
  apk del build-dependencies

# ローカルにある全てのファイルをイメージにコピー
COPY . .

# 生成されたコンテナ内で実行したいコマンドを指定
CMD ["rails", "server", "-b", "0.0.0.0"]