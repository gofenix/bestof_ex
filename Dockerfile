FROM hexpm/elixir:1.18.3-erlang-27.2.4-alpine-3.21.3

RUN apk add --no-cache build-base git openssl ncurses-libs

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix deps.get

COPY . .
RUN mix deps.compile

EXPOSE 4000

CMD ["mix", "nex.start"]
