FROM ruby:3.2.2-slim

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev

# 作業ディレクトリの設定
WORKDIR /rails

# 環境変数の設定
ENV RAILS_ENV=development

# GemfileとGemfile.lockのコピー
COPY Gemfile* ./

# Bundlerでgemをインストール
RUN bundle install

# アプリケーションのコピー
COPY . .

# ポート3000を開放
EXPOSE 3000

# サーバー起動コマンド
CMD ["rails", "server", "-b", "0.0.0.0"]