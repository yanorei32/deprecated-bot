FROM rust:1.68.0 as build-env
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

FROM debian:bullseye@sha256:7b991788987ad860810df60927e1adbaf8e156520177bd4db82409f81dd3b721

COPY --chown=root:root --from=build-env \
	/usr/src/deprecated-bot/CREDITS \
	/usr/src/deprecated-bot/LICENSE \
	/usr/share/licenses/deprecated-bot/

COPY --chown=root:root --from=build-env \
	/usr/src/deprecated-bot/target/release/deprecated-bot \
	/usr/bin/deprecated-bot

CMD ["/usr/bin/deprecated-bot"]
