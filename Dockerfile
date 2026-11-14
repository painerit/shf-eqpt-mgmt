FROM ruby:3.2-slim

WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  git \
  curl \
  libvips

RUN gem install bundler

COPY Gemfile Gemfile.lock* ./

RUN bundle install

COPY . /app

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]