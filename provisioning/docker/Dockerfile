FROM debian:bullseye-slim
ARG user=docker
ARG UID=1000
ARG GID=1000
ARG DEBIAN_FRONTEND=noninteractive
ARG sops_version=3.7.1

RUN useradd --uid=${UID} -ms /bin/bash $user \
    && mkdir -p /workdir \
    && chown ${UID}:${GID} /workdir

VOLUME ["/workdir"]

RUN apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends \
    curl \
    apt-utils \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    lsb-release \
    python3-pip \
    krb5-config \
    krb5-user \
    python3-venv \
    && apt-get clean all

# ENV SOPSV=$sops_version
# RUN curl -L "https://github.com/mozilla/sops/releases/download/v${sops_version}/sops_${sops_version}_amd64.deb" --output /tmp/sops.deb \
#     && dpkg -i /tmp/sops.deb \
#     && rm /tmp/sops.deb

# Add terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && curl -L "https://github.com/mozilla/sops/releases/download/v${sops_version}/sops_${sops_version}_amd64.deb" --output /tmp/sops.deb \
    && dpkg -i /tmp/sops.deb \
    && apt-get update -qq && apt-get install -qqy \
    terraform \
    kubectl \
    openssh-client \
    && rm -f /tmp/sops.deb


WORKDIR /provisioning
USER ${UID}:${GID}
ENV PATH="/home/${user}/.local/bin:/usr/bin/:/bin/:${PATH}"
RUN pip install --upgrade pip && python3 -m venv /home/$user/provisioner \
    && /bin/bash -c "source /home/$user/provisioner/bin/activate" \
    && pip install ansible \
    && mkdir -p /home/${user}/.ssh \
    && touch /home/${user}/.ssh/known_hosts

WORKDIR /workdir

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]