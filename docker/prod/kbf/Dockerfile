FROM elixir:1.14.2-slim

ENV MIX_ENV prod
ENV NODE_ENV production

WORKDIR /opt/kbf
COPY config ./config
COPY priv ./priv
COPY lib ./lib
COPY assets ./assets
COPY mix.exs mix.lock ./

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod \
  && mix compile

RUN apt-get update \
  && apt-get install -y gcc g++ make curl \
  && curl -O https://deb.nodesource.com/setup_16.x \
  && bash setup_16.x \
  && rm setup_16.x \
  && apt-get install -y build-essential nodejs
RUN npm install --omit=dev --prefix assets \
  && npm run deploy --prefix assets \
  && mix phx.digest

ENTRYPOINT mix ecto.migrate && mix phx.server
