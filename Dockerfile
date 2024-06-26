ARG ELIXIR_VERSION=1.17.0
ARG OTP_VERSION=otp-27
ARG ARCH

FROM ${ARCH}elixir:${ELIXIR_VERSION}-${OTP_VERSION}-alpine AS elixir

FROM papereira/devcontainer-base:0.2.2
ARG VERSION=
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
LABEL \
  org.opencontainers.image.authors="pauloalvespereira@live.com" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.url="https://github.com/pap/devcontainer-elixir" \
  org.opencontainers.image.documentation="https://github.com/pap/devcontainer-elixir" \
  org.opencontainers.image.source="https://github.com/pap/devcontainer-elixir" \
  org.opencontainers.image.title="Alpine Elixir Dev container" \
  org.opencontainers.image.description="Elixir development container for Visual Studio Code Remote Containers development"
ENV ELIXIR_IMAGE_VERSION="${VERSION}"
USER root
COPY --from=elixir /usr/local/lib/erlang /usr/local/lib/erlang
COPY --from=elixir /usr/local/lib/elixir /usr/local/lib/elixir
COPY --from=elixir /usr/local/bin /usr/local/bin

# Install Alpine packages (NPM)
RUN apk update && \
  apk --no-cache --update --progress add \
  make \
  g++ \
  wget \
  starship \
  inotify-tools && \
  rm -rf /var/cache/apk/*

# Shell setup
COPY --chown=${USER_UID}:${USER_GID} shell/.zshrc-specific shell/.welcome.sh /home/${USERNAME}/
COPY shell/.zshrc-specific shell/.welcome.sh /root/

USER ${USERNAME}

# enable iex history
ENV ERL_AFLAGS="-kernel shell_history enabled shell_history_path '\"/home/${USERNAME}/.erlang-history\"'"
# Ensure latest versions of Hex/Rebar are installed on build
RUN mix do local.hex --force, local.rebar --force
