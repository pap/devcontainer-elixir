ARG ELIXIR_VERSION=1.10.4

FROM elixir:${ELIXIR_VERSION}-alpine AS elixir

FROM papereira/devcontainer-base:alpine
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=local
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
LABEL \
  org.opencontainers.image.authors="paulo.alves.pereira@hey.com" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.url="https://github.com/pap/devcontainer-elixir" \
  org.opencontainers.image.documentation="https://github.com/pap/devcontainer-elixir" \
  org.opencontainers.image.source="https://github.com/pap/devcontainer-elixir" \
  org.opencontainers.image.title="Alpine Elixir Phoenix Dev container" \
  org.opencontainers.image.description="Elixir Phoenix development container for Visual Studio Code Remote Containers development"
ENV ELIXIR_IMAGE_VERSION="${VERSION}-${BUILD_DATE}-${VCS_REF}"
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
  curl \
  inotify-tools && \
  rm -rf /var/cache/apk/*

# Shell setup
COPY --chown=${USER_UID}:${USER_GID} shell/.zshrc-specific shell/.welcome.sh /home/${USERNAME}/
COPY shell/.zshrc-specific shell/.welcome.sh /root/

USER ${USERNAME}

# install starship prompt
RUN curl -fsSL https://starship.rs/install.sh -o install.sh && \
  zsh ./install.sh --yes && \
  rm install.sh

# enable iex history
ENV ERL_AFLAGS="-kernel shell_history enabled shell_history_path '\"/home/${USERNAME}/.erlang-history\"'"
# Ensure latest versions of Hex/Rebar are installed on build
RUN mix do local.hex --force, local.rebar --force
