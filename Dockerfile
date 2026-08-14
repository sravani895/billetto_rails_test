# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.3.6
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# Build stage to compile gems & assets
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for application image
FROM base

# Install packages needed for runtime & postgres client
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq-dev postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built gems and application code
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run as non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log tmp storage
USER 1000:1000

# Entrypoint script
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port and run Puma by default
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
