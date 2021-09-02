FROM mcr.microsoft.com/vscode/devcontainers/python 

ENV DEBIAN_FRONTEND noninteractive
ARG USERNAME=code
ARG USER_UID=1000
ARG USER_GID=$USER_UID


ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 SHELL=/bin/bash
ENV LANGUAGE=${LANG} TZ=Asia/Seoul
ENV PATH=/usr/local/coder:/opt/conda/bin:$PATH


RUN DEBIAN_FRONTEND=noninteractive && apt update && apt install -y --no-install-recommends \
    apt-transport-https \
    tor \
    gnupg2 \
    pass \
    sudo \
    curl \
    wget \
    ssh \
    iptables \
    dnsutils \
    net-tools \
    tree \
    rsync \
    sqlite3 \
    ncat \
    socat \
    openvpn \
    git \
    inetutils-ping \
    traceroute \
    dnsmasq \
    firejail \
    busybox \
    unzip \
    python3-venv \
    python3-distutils \
    gcc \
    g++ \
    make \
    htop \
    nano \
    ncdu \
    uwsgi \
    uwsgi-plugin-python3 \
    redis \
    redis-server \
    rsyslog \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

##其他辅助相关的包

RUN DEBIAN_FRONTEND=noninteractive && apt update && apt install -y --no-install-recommends \
    tcpdump \
    rsyslog \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


ENV GITHUB_ROOT_DIR=/code/github
RUN mkdir -p /code/github/ && \
    git clone https://github.com/microsoft/vscode-dev-containers.git ${GITHUB_ROOT_DIR}/vscode-dev-containers

# nodejs 16
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt update \
    &&apt-get install -y nodejs \
    # Install npm , yarn, nvm
    && npm install -g npm \
    && rm -rf /opt/yarn-* /usr/local/bin/yarn /usr/local/bin/yarnpkg \
    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -q \
    && apt-get -q install yarn \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*



RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    ## wireguard
    && echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list \
    && printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable \
    && apt update && apt install -y wireguard-dkms wireguard-tools \
    # && apt-get update -q && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh \
    # && sudo apt remove -y docker-compose \
    # && sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    # && sudo chmod +x /usr/local/bin/docker-compose \
    # && sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


# frpc
RUN wget -q -O frp_0.36.2_linux_386.tar.gz https://github.com/fatedier/frp/releases/download/v0.36.2/frp_0.36.2_linux_386.tar.gz  \
    && tar vxzf frp_0.36.2_linux_386.tar.gz && rm frp_0.36.2_linux_386.tar.gz \
    && sudo cp frp_0.36.2_linux_386/frpc /usr/local/bin && sudo chmod +x /usr/local/bin/frpc  \
    && sudo cp frp_0.36.2_linux_386/frps /usr/local/bin && sudo chmod +x /usr/local/bin/frps  \
    && rm -rdf frp_0.36.2_linux_386 

RUN ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && git config --global user.name a  \
    && git config --global user.email a@a.a \
    && git config --global core.autocrlf input

ENV vscode_commit_id=379476f0e13988d90fab105c5c19e7abc8b1dea8
RUN mkdir -p ~/.vscode-server/bin \
    && wget -O /tmp/vscode-server.tar.gz https://update.code.visualstudio.com/commit:${vscode_commit_id}/server-linux-x64/stable \ 
    && cd  ~/.vscode-server/bin \
    && cd /tmp && tar -xf vscode-server.tar.gz \
    && mv /tmp/vscode-server-linux-x64 ~/.vscode-server/bin/${vscode_commit_id} \
    && rm /tmp/vscode-server.tar.gz

RUN curl -L -o 1.vsix.zip https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-azuretools/vsextensions/vscode-docker/1.16.0/vspackage



# 1.19.2 
ENV NGINX_VERSION='1.20.1' 
RUN git clone https://github.com/chobits/ngx_http_proxy_connect_module.git /tmp/ngx_http_proxy_connect_module \
    && wget -q -O nginx-${NGINX_VERSION}.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz && rm nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && patch -p1 < /tmp/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_1018.patch\
    #/etc/nginx/modules/ngx_http_proxy_connect_module.so
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module --with-http_secure_link_module \
        --with-http_slice_module --with-http_ssl_module \
        --with-http_stub_status_module --with-http_sub_module \
        --with-http_v2_module --with-mail --with-mail_ssl_module \
        --with-stream --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --add-dynamic-module=/tmp/ngx_http_proxy_connect_module \
    && make && make install \
    && cd .. && rm -rdf  nginx-${NGINX_VERSION}



RUN pip install --upgrade pip


# jupyterlab(jupyter lab --ip 0.0.0.0 --allow-root --port 48822 --no-browser)
RUN pip install jupyterlab

RUN curl -fsSL https://code-server.dev/install.sh | sh \
    && code-server --install-extension ms-azuretools.vscode-docker \
        ms-python.python \
        donjayamanne.githistory \
        eamodio.gitlens \
        yzhang.markdown-all-in-one

RUN npm i -g typescript ts-node @nestjs/cli


VOLUME [ "/var/lib/docker" ]
VOLUME [ "/code/nodebackend" ]