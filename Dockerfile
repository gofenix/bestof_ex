FROM elixir:1.18-alpine

RUN apk add --no-cache build-base git openssl ncurses-libs

WORKDIR /app

ENV HEX_HTTP_TIMEOUT=120000
ENV HEX_HTTP_CONCURRENCY=1

RUN mix local.hex --force --if-missing && \
    mix local.rebar --force --if-missing

COPY . .

RUN mix deps.get

EXPOSE 4000

CMD ["mix", "nex.start"]
