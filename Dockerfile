FROM rust:1.65.0 as build-env
LABEL maintainer="yanorei32"

WORKDIR /usr/src
RUN cargo new deprecated-bot
COPY Cargo.toml Cargo.lock /usr/src/deprecated-bot/
WORKDIR /usr/src/deprecated-bot
RUN cargo build --release

COPY src/* /usr/src/deprecated-bot/src/
RUN touch src/* && cargo build --release

FROM debian:bullseye@sha256:3066ef83131c678999ce82e8473e8d017345a30f5573ad3e44f62e5c9c46442b

COPY --chown=root:root \
	./target/release/deprecated-bot \
	/usr/bin/deprecated-bot

CMD ["/usr/bin/deprecated-bot"]
