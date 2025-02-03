# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20240513-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.15.7-erlang-26.1.2-debian-bullseye-20240513-slim
#
ARG ELIXIR_VERSION=1.15.7
ARG OTP_VERSION=26.1.2
ARG DEBIAN_VERSION=bullseye-20240513-slim
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS install_stage

RUN apt-get update -y && apt-get install -y build-essential git postgresql-client inotify-tools \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

# RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN git clone https://github.com/denvaar/my_app.git .
COPY .env .

RUN mix deps.get
RUN mix compile

FROM install_stage as setup_stage
# COPY --from=0 /app /app
# FROM ${RUNNER_IMAGE} as runner
# COPY --from=builder /app /app
# WORKDIR /app
# RUN mix ecto.create
# RUN mix ecto.migrate

# ENTRYPOINT ["iex -S mix"]
ENTRYPOINT ["/bin/bash"]
