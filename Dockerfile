FROM httpd:alpine



ENV CGIT_TITLE="CGit"
ENV CGIT_DESC="The hyperfast web frontend for Git repositories"
ENV CGIT_VROOT="/"
ENV CGIT_SECTION_FROM_STARTPATH=0
ENV CGIT_MAX_REPO_COUNT=50
ENV AUTH_TTL=600



RUN apk add --no-cache ca-certificates tzdata sudo gettext dumb-init \
                       vim htop bash git curl \
                       xz zlib \
                       python3 py3-markdown py3-pygments \
                       openssh-server cgit redis


RUN adduser "git" --no-create-home --home /var/www --uid 1000 --disabled-password --shell /bin/bash && \
    echo "git:$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 128 )" | chpasswd


RUN mkdir -p /var/cache/cgit && chown git:git /var/cache/cgit
RUN mkdir -p /cgit           && chown git:git /cgit
RUN mkdir -p /var/www        && chown git:git /var/www
RUN mkdir -p /config

COPY sshd_config /etc/ssh/sshd_config

###################################################

ADD docker-entrypoint.sh set_root_pw.sh /
ADD cgit-simple-authentication /opt/cgit-simple-authentication 
ADD scripts/* /usr/local/bin/

RUN chown git:git /opt/cgit-simple-authentication && chmod +Xx /opt/cgit-simple-authentication

ADD cgitrc /tmp/cgitrc.tmpl    
ADD httpd.conf /usr/local/apache2/conf/httpd.conf

WORKDIR "/var/www/"

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD "httpd-foreground"


EXPOSE 80 22           
