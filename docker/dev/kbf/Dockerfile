FROM elixir:1.12.0-slim

RUN apt-get update && apt-get install -y inotify-tools curl

RUN mix local.hex --force && mix local.rebar --force

RUN apt-get install -y gcc g++ make \
  && curl -O https://deb.nodesource.com/setup_14.x \
  && bash setup_14.x \
  && rm setup_14.x \
  && apt-get install -y build-essential nodejs
