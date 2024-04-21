FROM debian AS builder

RUN apt-get update && \
    apt-get install -y ca-certificates tzdata sudo \
                       vim htop bash git curl \
                       python3 \
                       make gcc pkg-config gettext liblua5.1-0-dev openssl libssl-dev libz-dev

RUN git clone --recurse-submodules https://git.zx2c4.com/cgit /build
RUN cd /build && make LUA_PKGCONFIG=lua5.1
RUN cd /build && make install

RUN ln -s cgit.cgi /var/www/htdocs/cgit/cgit


FROM httpd:latest



ENV CGIT_TITLE="CGit"
ENV CGIT_DESC="The hyperfast web frontend for Git repositories"
ENV CGIT_VROOT="/"
ENV CGIT_SECTION_FROM_STARTPATH=0
ENV CGIT_LOG_PAGESIZE=50
ENV CGIT_REPO_PAGESIZE=50
ENV CGIT_CACHE=1
ENV CGIT_AUTH=0
ENV DEFAULT_USER=""
ENV DEFAULT_PASS=""

ENV AUTH_TTL=604800
ENV DOMAIN="localhost"
ENV SSHPORT=22



RUN apt-get update && \
    apt-get install -y ca-certificates tzdata sudo gettext dumb-init \
                       vim htop bash git curl \
                       python3 python3-markdown python3-pygments \
                       openssh-server libssl-dev luarocks && \
    luarocks install luaossl  && \
    luarocks install luaposix && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
                       


RUN adduser "git" --no-create-home --home /var/www --uid 1000 --disabled-password --shell /bin/bash && \
    echo "git:$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 128 )" | chpasswd


COPY --from=builder /var/www/htdocs/cgit/         /usr/share/webapps/cgit/
COPY --from=builder /usr/local/lib/cgit/filters/  /usr/lib/cgit/filters/

RUN mkdir -p /var/cache/cgit && chown git:git /var/cache/cgit
RUN mkdir -p /cgit           && chown git:git /cgit
RUN mkdir -p /var/www        && chown git:git /var/www
RUN mkdir -p /config

ADD sshd_config     /etc/ssh/sshd_config
ADD cgit-dark.css   /usr/share/webapps/cgit/cgit-dark.css

###################################################

ADD docker-entrypoint.sh set_root_pw.sh /
ADD scripts/* /usr/local/bin/

ADD cgitrc     /tmp/cgitrc.tmpl    
ADD httpd.conf /usr/local/apache2/conf/httpd.conf
ADD auth.lua   /tmp/auth.lua

WORKDIR "/var/www/"

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD "httpd-foreground"


EXPOSE 80 22           
