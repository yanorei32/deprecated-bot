FROM rust:1.68.1 as build-env
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

FROM debian:bullseye@sha256:f81bf5a8b57d6aa1824e4edb9aea6bd5ef6240bcc7d86f303f197a2eb77c430f

COPY --chown=root:root --from=build-env \
	/usr/src/deprecated-bot/CREDITS \
	/usr/src/deprecated-bot/LICENSE \
	/usr/share/licenses/deprecated-bot/

COPY --chown=root:root --from=build-env \
	/usr/src/deprecated-bot/target/release/deprecated-bot \
	/usr/bin/deprecated-bot

CMD ["/usr/bin/deprecated-bot"]
