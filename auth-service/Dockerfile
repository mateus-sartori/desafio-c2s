# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.7

###################################
# Base (runtime only)
###################################
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libjemalloc2 \
      libpq5 \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"
    

###################################
# Build stage
###################################
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle \
           ${BUNDLE_PATH}/ruby/*/cache \
           ${BUNDLE_PATH}/ruby/*/bundler/gems/*/.git

COPY . .

# Opcional
RUN bundle exec bootsnap precompile -j 1 --gemfile
RUN bundle exec bootsnap precompile -j 1 app/ lib/

###################################
# Final image
###################################
FROM base

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

USER rails

COPY --from=build --chown=rails:rails ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build --chown=rails:rails /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
