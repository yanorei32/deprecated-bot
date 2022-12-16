FROM rust:1.66.0 as build-env
LABEL maintainer="yanorei32"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /usr/src
RUN cargo new deprecated-bot
COPY LICENSE Cargo.toml Cargo.lock /usr/src/deprecated-bot/
WORKDIR /usr/src/deprecated-bot
RUN	cargo install cargo-license && cargo license \
	--authors \
	--do-not-bundle \
	--avoid-dev-deps \
	--avoid-build-deps \
	--filter-platform "$(rustc -vV | sed -n 's|host: ||p')" \
	> CREDITS

RUN cargo build --release
COPY src/* /usr/src/deprecated-bot/src/
RUN touch src/* && cargo build --release

FROM debian:bullseye@sha256:a288aa7ad0e4d443e86843972c25a02f99e9ad6ee589dd764895b2c3f5a8340b

COPY --chown=root:root --from=build-env \
	/usr/src/deprecated-bot/CREDITS \
	/usr/src/deprecated-bot/LICENSE \
	/usr/share/licenses/deprecated-bot/

COPY --chown=root:root --from=build-env \
	/usr/src/deprecated-bot/target/release/deprecated-bot \
	/usr/bin/deprecated-bot

CMD ["/usr/bin/deprecated-bot"]
