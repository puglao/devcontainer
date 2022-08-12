FROM debian:bullseye-slim
ARG TARGETARCH
ARG TARGETPLATFORM

# Install generic apt packages
RUN apt update && apt install -y \
    curl \
    dnsutils \
    git \
    jq \
    sudo \
    vim \
    zsh 
RUN apt clean


#chsh to /usr/bin/zsh for root
RUN chsh -s /usr/bin/zsh root

# Create user vscode and add it to sudoers
# password hash is created with (openssl passwd <plain-text-password>)
ARG VSCODE_PASSWORD_HASH=$1$5WC/L8rp$Qwm60qVWtTiIZEfgdqLfj1
RUN groupadd -g 1000 vscode \
    && useradd -u 1000 -g 1000 -s /usr/bin/zsh -m -p '${VSCODE_PASSWORD_HASH}' vscode \
    && echo "vscode ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vscode

# Install Oh My Zsh! as root
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattend
RUN mkdir -p /root/.oh-my-zsh/completions \
    && echo "# Enable autocompletion\nautoload -U compinit; compinit\n" >> /root/.zshrc
# Install Oh My Zsh! as user vscode
USER vscode
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattend
RUN mkdir -p /home/vscode/.oh-my-zsh/completions \
    && echo "# Enable autocompletion\nautoload -U compinit; compinit\n" >> /home/vscode/.zshrc
USER root


# Install starship Prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -f
RUN echo '# Initiate starship\neval "$(starship init zsh)"\n' >> /root/.zshrc
COPY lib/starship-root.toml /root/.config/starship.toml
RUN starship completions zsh > /root/.oh-my-zsh/completions/_starship
RUN echo '# Initiate starship\neval "$(starship init zsh)"\n' >> /home/vscode/.zshrc
COPY --chown=vscode:vscode lib/starship.toml /home/vscode/.config/starship.toml
RUN starship completions zsh > /home/vscode/.oh-my-zsh/completions/_starship


# Fix locale
RUN apt install locales -y && apt clean
RUN locale-gen \
    && sed -i -E 's/^# (en_US.UTF-8 UTF-8)$/\1/' /etc/locale.gen \
    && locale-gen \
    && sed -i -E 's/# (export LANG.*)/\1/' /root/.zshrc \
    && sed -i -E 's/# (export LANG.*)/\1/' /home/vscode/.zshrc

# Install zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN plugin=zsh-autosuggestions; sed -i -E "s/^plugins=\(([^)]*)\)/plugins=\(\n\1\n$plugin\n\)/" /root/.zshrc
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/vscode/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN chown -R vscode:vscode /home/vscode/.oh-my-zsh/custom/plugins/
RUN plugin=zsh-autosuggestions; sed -i -E "s/^plugins=\(([^)]*)\)/plugins=\(\n\1\n$plugin\n\)/" /home/vscode/.zshrc

# Extend zsh history file size
RUN echo '# Extend zsh history file size\nexport HISTSIZE=1000000000\nexport SAVEHIST=$HISTSIZE\nsetopt EXTENDED_HISTORY\n' >> /root/.zshrc
RUN echo '# Extend zsh history file size\nexport HISTSIZE=1000000000\nexport SAVEHIST=$HISTSIZE\nsetopt EXTENDED_HISTORY\n' >> /home/vscode/.zshrc

# Install yq
ARG YQ_VERSION=v4.25.3
ARG YQ_BINARY_ARCH=${TARGETARCH}
RUN curl -sL https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${YQ_BINARY_ARCH}.tar.gz |\
    tar xz && mv yq_linux_${YQ_BINARY_ARCH} /usr/bin/yq
RUN yq shell-completion zsh > "/root/.oh-my-zsh/completions/_yq"
RUN yq shell-completion zsh > "/home/vscode/.oh-my-zsh/completions/_yq"

CMD ["zsh"]


